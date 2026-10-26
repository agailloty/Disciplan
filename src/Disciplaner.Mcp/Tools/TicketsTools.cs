using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Enums;
using Disciplaner.Mcp.Resolution;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

[McpServerToolType]
public sealed class TicketsTools
{
    private readonly McpToolContext _context;
    private readonly McpReferenceResolver _resolver;
    private readonly ITicketService _tickets;
    private readonly ICommentService _comments;
    private readonly ISprintService _sprints;

    public TicketsTools(
        McpToolContext context,
        McpReferenceResolver resolver,
        ITicketService tickets,
        ICommentService comments,
        ISprintService sprints)
    {
        _context = context;
        _resolver = resolver;
        _tickets = tickets;
        _comments = comments;
        _sprints = sprints;
    }

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Returns one ticket's full details: description, status (with its category), type, priority, story points, due date, sprint, assignee, reporter and labels. Identify the ticket by its reference 'KEY-number' (e.g. 'DISC-42', case-insensitive) or by GUID id.")]
    public async Task<Projections.McpTicketDetail> GetTicket(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string? ticket_ref = null,
        [Description("Ticket GUID id (alternative to ticket_ref).")] string? ticket_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, ticket_id, _context.UserId, ct);
            return Projections.ToTicketDetail(ticket);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Searches tickets with filters: by project (key or id), sprint, status category (Backlog|InProgress|Done), type (Story|Bug|Task|Epic|Subtask), assignee, or only your own ('mine'). " +
        "Without 'project_key', the search covers all your accessible projects. Use it to browse the backlog or find tickets before updating them.")]
    public async Task<Projections.McpPage<Projections.McpTicket>> ListTickets(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive. Omit to search all accessible projects.")] string? project_key = null,
        [Description("Project GUID id (alternative to project_key).")] string? project_id = null,
        [Description("Sprint name within the project, case-insensitive.")] string? sprint_name = null,
        [Description("Sprint GUID id (alternative to sprint_name).")] string? sprint_id = null,
        [Description("Status category: Backlog|InProgress|Done.")] string? status_category = null,
        [Description("Ticket type: Story|Bug|Task|Epic|Subtask.")] string? type = null,
        [Description("Assignee display name (requires project_key).")] string? assignee_display_name = null,
        [Description("Only tickets assigned to you (true/false).")] bool? mine = null,
        [Description("Maximum number of tickets to return (1-100, default 50).")] int? limit = null,
        [Description("Number of tickets to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var userId = _context.UserId;
            var (take, skip) = _context.NormalizePaging(limit, offset);

            Guid? projectId = null;
            if (!string.IsNullOrWhiteSpace(project_key) || !string.IsNullOrWhiteSpace(project_id))
                projectId = (await _resolver.ResolveProjectAsync(project_key, project_id, userId, ct)).Id;

            Guid? sprintId = null;
            if (sprint_id is not null && Guid.TryParse(sprint_id, out var sid))
            {
                sprintId = sid;
            }
            else if (!string.IsNullOrWhiteSpace(sprint_name))
            {
                if (projectId is null)
                    throw new McpException("'sprint_name' requires 'project_key' (or 'project_id') to know which project to search.");
                var project = await _resolver.ResolveProjectAsync(project_key, project_id, userId, ct);
                sprintId = (await _resolver.ResolveSprintAsync(project.Id, project.Key, sprint_name, userId, ct)).Id;
            }

            string? assigneeId = null;
            if (!string.IsNullOrWhiteSpace(assignee_display_name))
            {
                if (projectId is null)
                    throw new McpException("'assignee_display_name' requires 'project_key' (or 'project_id') to know which project to search.");
                var project = await _resolver.ResolveProjectAsync(project_key, project_id, userId, ct);
                assigneeId = (await _resolver.ResolveMemberAsync(project.Id, project.Key, assignee_display_name, userId, ct)).UserId;
            }

            Disciplaner.Domain.Enums.StatusCategory? category = null;
            if (status_category is not null)
            {
                if (!Enum.TryParse<StatusCategory>(status_category, ignoreCase: true, out var parsed))
                    throw new McpException($"'{status_category}' is not a valid status category. Valid values: {string.Join(", ", Enum.GetNames<StatusCategory>())}.");
                category = parsed;
            }

            Disciplaner.Domain.Enums.TicketType? ticketType = null;
            if (type is not null)
                ticketType = McpInputParsing.ParseTicketType(type);

            var query = new TicketSearchQuery
            {
                ProjectId = projectId,
                SprintId = sprintId,
                StatusCategory = category,
                Type = ticketType,
                AssigneeId = assigneeId,
                AssignedToMe = mine == true,
                Limit = take,
                Offset = skip
            };

            var result = await _tickets.SearchAsync(query, userId, ct);
            return new Projections.McpPage<Projections.McpTicket>(
                result.Items.Select(Projections.ToTicket).ToList(), result.TotalCount, skip, take);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the comments of a ticket, oldest first, with author and content.")]
    public async Task<Projections.McpPage<Projections.McpComment>> ListComments(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("Maximum number of comments to return (1-100, default 50).")] int? limit = null,
        [Description("Number of comments to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, null, _context.UserId, ct);
            var comments = await _comments.GetByTicketAsync(ticket.Id, _context.UserId, ct);
            return Projections.Page(comments.Select(Projections.ToComment).ToList(), take, skip);
        });
}
