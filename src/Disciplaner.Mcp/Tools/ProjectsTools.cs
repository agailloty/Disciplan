using Disciplaner.Application.Interfaces;
using Disciplaner.Mcp.Resolution;
using ModelContextProtocol;
using Disciplaner.Mcp.Tools;
using Microsoft.AspNetCore.Http;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

[McpServerToolType]
public sealed class ProjectsTools
{
    private readonly McpToolContext _context;
    private readonly McpReferenceResolver _resolver;
    private readonly IProjectService _projects;
    private readonly IProjectMemberService _members;
    private readonly ILabelService _labels;

    public ProjectsTools(
        McpToolContext context,
        McpReferenceResolver resolver,
        IProjectService projects,
        IProjectMemberService members,
        ILabelService labels)
    {
        _context = context;
        _resolver = resolver;
        _projects = projects;
        _members = members;
        _labels = labels;
    }

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the projects you can access, with their short key (e.g. 'DISC'), ticket and sprint counts, and your role. Start here to discover project keys used by all other tools.")]
    public async Task<Projections.McpPage<Projections.McpProject>> ListProjects(
        [Description("Maximum number of projects to return (1-100, default 50).")] int? limit = null,
        [Description("Number of projects to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);
            var projects = await _projects.GetAllByUserAsync(_context.UserId, ct);
            return Projections.Page(projects.Select(Projections.ToProject).ToList(), take, skip);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Returns one project's details: its custom ticket statuses (with category Backlog/InProgress/Done), its members and their roles, and the default ticket type. Identify the project by its short key (e.g. 'DISC', case-insensitive) or by GUID id.")]
    public async Task<Projections.McpProjectDetail> GetProject(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive.")] string? project_key = null,
        [Description("Project GUID id (alternative to project_key).")] string? project_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var summary = await _resolver.ResolveProjectAsync(project_key, project_id, _context.UserId, ct);
            var detail = await _projects.GetByIdAsync(summary.Id, _context.UserId, ct)
                ?? throw new McpException($"Project '{summary.Key}' is not accessible with this account.");
            return Projections.ToProjectDetail(detail);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the members of a project with their display names and roles (Guest, Member, Supervisor, Owner/Admin). Display names can be used as 'assignee' in ticket tools.")]
    public async Task<Projections.McpPage<Projections.McpMember>> ListMembers(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive.")] string project_key,
        [Description("Maximum number of members to return (1-100, default 50).")] int? limit = null,
        [Description("Number of members to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);
            var project = await _resolver.ResolveProjectAsync(project_key, _context.UserId, ct);
            var members = await _members.GetMembersAsync(project.Id, _context.UserId, ct);
            return Projections.Page(
                members.Select(m => new Projections.McpMember(m.DisplayName, m.Email, m.Role.ToString())).ToList(),
                take, skip);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the custom ticket statuses of a project with their category (Backlog, InProgress or Done) and display order. The category is what matters when closing tickets.")]
    public async Task<Projections.McpPage<Projections.McpStatus>> ListTicketStatuses(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive.")] string project_key,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var project = await _resolver.ResolveProjectAsync(project_key, _context.UserId, ct);
            var detail = await _projects.GetByIdAsync(project.Id, _context.UserId, ct)
                ?? throw new McpException($"Project '{project.Key}' is not accessible with this account.");
            return Projections.Page(detail.Statuses.Select(Projections.ToStatus).ToList(), 100, 0);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the label catalog (name + color). Labels are shared across projects in Disciplaner; tickets carry the labels that apply to them.")]
    public async Task<Projections.McpPage<Projections.McpLabel>> ListLabels(
        [Description("Maximum number of labels to return (1-100, default 50).")] int? limit = null,
        [Description("Number of labels to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);
            var labels = await _labels.GetAllAsync(ct);
            return Projections.Page(labels.Select(Projections.ToLabel).ToList(), take, skip);
        });
}
