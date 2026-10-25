using Disciplaner.Application.Interfaces;
using Disciplaner.Mcp.Resolution;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

[McpServerToolType]
public sealed class SprintsTools
{
    private readonly McpToolContext _context;
    private readonly McpReferenceResolver _resolver;
    private readonly ISprintService _sprints;
    private readonly ITicketService _tickets;
    private readonly IProjectService _projectsForListing;

    public SprintsTools(
        McpToolContext context,
        McpReferenceResolver resolver,
        ISprintService sprints,
        ITicketService tickets,
        IProjectService projects)
    {
        _context = context;
        _resolver = resolver;
        _sprints = sprints;
        _tickets = tickets;
        _projectsForListing = projects;
    }

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists sprints with their status (Planned, Active or Closed), dates and ticket counts. Scope to one project with its key, or list the sprints of all your accessible projects. Each sprint carries a 'sprint_id' used by sprint tools.")]
    public async Task<Projections.McpPage<Projections.McpSprint>> ListSprints(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive. Omit to list sprints of all accessible projects.")] string? project_key = null,
        [Description("Maximum number of sprints to return (1-100, default 50).")] int? limit = null,
        [Description("Number of sprints to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);

            IReadOnlyList<(Disciplaner.Application.DTOs.Sprint.SprintDto Sprint, string ProjectKey)> keyed;
            if (project_key is null)
            {
                // All accessible projects: sprints of every status (planned sprints carry no dates,
                // so the dated-only "for user" queries are not usable here).
                var all = new List<(Disciplaner.Application.DTOs.Sprint.SprintDto, string)>();
                foreach (var project in await _projectsForListing.GetAllByUserAsync(_context.UserId, ct))
                    foreach (var sprint in await _sprints.GetByProjectAsync(project.Id, _context.UserId, ct))
                        all.Add((sprint, project.Key));
                keyed = all;
            }
            else
            {
                var project = await _resolver.ResolveProjectAsync(project_key, _context.UserId, ct);
                keyed = (await _sprints.GetByProjectAsync(project.Id, _context.UserId, ct))
                    .Select(s => (s, project.Key)).ToList();
            }

            // GetByProjectAsync does not populate ProjectKey on the DTOs; pass it explicitly.
            return Projections.Page(
                keyed.Select(k => Projections.ToSprint(k.Sprint, k.ProjectKey)).ToList(), take, skip);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Returns a sprint's details and the tickets it contains (reference, status, assignee). Identify the sprint by name within a project ('sprint_name' + 'project_key') or by 'sprint_id' from list_sprints.")]
    public async Task<Projections.McpSprintDetail> GetSprint(
        [Description("Sprint name within the project, e.g. 'Sprint 12'. Case-insensitive.")] string? sprint_name = null,
        [Description("Short project key, e.g. 'DISC'. Required with sprint_name.")] string? project_key = null,
        [Description("Sprint GUID id (alternative to sprint_name + project_key).")] string? sprint_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();

            var (sprint, projectKey) = await ResolveSprintAsync(sprint_name, project_key, sprint_id, ct);
            var tickets = await _tickets.GetBySprintAsync(sprint.Id, _context.UserId, ct);
            return Projections.ToSprintDetail(sprint, tickets);
        });

    private async Task<(Disciplaner.Application.DTOs.Sprint.SprintDetailDto, string)> ResolveSprintAsync(
        string? sprintName, string? projectKey, string? sprintId, CancellationToken ct)
    {
        if (sprintId is not null && Guid.TryParse(sprintId, out var id))
        {
            var sprint = await _sprints.GetByIdAsync(id, _context.UserId, ct)
                ?? throw new McpException(
                    $"Sprint '{sprintId}' was not found or you don't have access to its project. " +
                    "Use list_sprints to browse your sprints.");
            return (sprint, sprint.ProjectKey);
        }

        if (!string.IsNullOrWhiteSpace(sprintName) && !string.IsNullOrWhiteSpace(projectKey))
        {
            var project = await _resolver.ResolveProjectAsync(projectKey, _context.UserId, ct);
            var summary = await _resolver.ResolveSprintAsync(project.Id, project.Key, sprintName, _context.UserId, ct);
            var sprint = await _sprints.GetByIdAsync(summary.Id, _context.UserId, ct)
                ?? throw new McpException($"Sprint '{sprintName}' was not found in project {project.Key}.");
            return (sprint, project.Key);
        }

        throw new McpException("Provide either 'sprint_id', or 'sprint_name' together with 'project_key'.");
    }
}
