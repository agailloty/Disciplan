using Disciplaner.Application.DTOs.Comment;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Common;
using Disciplaner.Mcp.Resolution;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

/// <summary>
/// Ticket and comment write tools. All require a 'read+write' token and at least the
/// Member project role (checked by the application services, not duplicated here).
/// </summary>
[McpServerToolType]
public sealed class TicketsWriteTools
{
    private readonly McpToolContext _context;
    private readonly McpReferenceResolver _resolver;
    private readonly ITicketService _tickets;
    private readonly ISprintService _sprints;
    private readonly ICommentService _comments;

    public TicketsWriteTools(
        McpToolContext context,
        McpReferenceResolver resolver,
        ITicketService tickets,
        ISprintService sprints,
        ICommentService comments)
    {
        _context = context;
        _resolver = resolver;
        _tickets = tickets;
        _sprints = sprints;
        _comments = comments;
    }

    public sealed record McpTicketWriteResult(string TicketRef, string Url, Projections.McpTicketDetail Ticket);

    public sealed record McpCommentWriteResult(string TicketRef, string Author, string Content, DateTime CreatedAt);

    // ── create_ticket ────────────────────────────────────────────────────────

    [McpServerTool(UseStructuredContent = true)]
    [Description("Creates one ticket in a project and returns its reference (e.g. 'FIXA-5') and a link to open it. " +
        "type: Story|Bug|Task|Epic|Subtask (default Task). priority: Low|Medium|High|Critical (default Medium). " +
        "The ticket starts in the project's default status; give 'sprint_name' to plan it into a sprint immediately. " +
        "To create several tickets at once, prefer the create_tickets batch tool.")]
    public async Task<McpTicketWriteResult> CreateTicket(
        [Description("Short project key, e.g. 'DISC'. Case-insensitive.")] string project_key,
        [Description("Ticket title (1-250 characters).")] string title,
        [Description("Optional description (plain text, up to 10000 characters).")] string? description = null,
        [Description("Ticket type: Story|Bug|Task|Epic|Subtask. Default Task.")] string? type = null,
        [Description("Priority: Low|Medium|High|Critical. Default Medium.")] string? priority = null,
        [Description("Optional story points (integer).")] int? story_points = null,
        [Description("Optional due date, ISO 8601, e.g. '2026-03-31'.")] string? due_date = null,
        [Description("Optional sprint name in the same project (case-insensitive) to plan the ticket into.")] string? sprint_name = null,
        [Description("Optional sprint GUID id (alternative to sprint_name).")] string? sprint_id = null,
        [Description("Optional parent ticket reference, e.g. 'DISC-42' (same project) to create a subtask.")] string? parent_ticket_ref = null,
        [Description("Optional assignee display name (project member, case-insensitive).")] string? assignee_display_name = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureWriteScope();
            var userId = _context.UserId;
            var project = await _resolver.ResolveProjectAsync(project_key, userId, ct);

            var request = new CreateTicketRequest(
                title,
                description,
                McpInputParsing.ParseTicketType(type),
                McpInputParsing.ParsePriority(priority),
                story_points,
                due_date is null ? null : McpInputParsing.ParseDate(due_date, "due_date"),
                await ResolveSprintIdAsync(project.Id, project.Key, sprint_name, sprint_id, userId, ct),
                await ResolveParentIdAsync(project.Id, project.Key, parent_ticket_ref, userId, ct),
                await ResolveAssigneeIdAsync(project.Id, project.Key, assignee_display_name, null, userId, ct));

            var ticket = await _tickets.CreateAsync(project.Id, userId, request, ct);
            return ToResult(ticket);
        });

    // ── update_ticket ───────────────────────────────────────────────────────

    [McpServerTool(UseStructuredContent = true)]
    [Description("Updates editable fields of a ticket: title, description, type, priority, story points, due date and assignee. " +
        "Only the fields you pass are changed. Status and sprint are NOT changed here (use close_ticket and move_ticket_to_sprint). " +
        "To change the assignee, pass 'assignee_display_name' (project member) or 'assignee_id'; use assign_ticket to unassign.")]
    public async Task<McpTicketWriteResult> UpdateTicket(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("New title (unchanged when omitted).")] string? title = null,
        [Description("New description (unchanged when omitted).")] string? description = null,
        [Description("New type: Story|Bug|Task|Epic|Subtask (unchanged when omitted).")] string? type = null,
        [Description("New priority: Low|Medium|High|Critical (unchanged when omitted).")] string? priority = null,
        [Description("New story points (unchanged when omitted).")] int? story_points = null,
        [Description("New due date, ISO 8601 (unchanged when omitted).")] string? due_date = null,
        [Description("New assignee display name (unchanged when omitted).")] string? assignee_display_name = null,
        [Description("New assignee GUID id (alternative to assignee_display_name).")] string? assignee_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureWriteScope();
            var userId = _context.UserId;
            var current = await _resolver.ResolveTicketAsync(ticket_ref, null, userId, ct);

            string? assignee;
            if (assignee_display_name is not null || assignee_id is not null)
                assignee = await ResolveAssigneeIdAsync(current.ProjectId, current.ProjectKey, assignee_display_name, assignee_id, userId, ct);
            else
                assignee = current.AssigneeId;

            var request = new UpdateTicketRequest(
                title ?? current.Title,
                description ?? current.Description,
                McpInputParsing.ParseTicketType(type, current.Type),
                McpInputParsing.ParsePriority(priority, current.Priority),
                story_points ?? current.StoryPoints,
                due_date is null ? current.DueDate : McpInputParsing.ParseDate(due_date, "due_date"),
                assignee);

            var ticket = await _tickets.UpdateAsync(current.Id, userId, request, ct);
            return ToResult(ticket);
        });

    // ── assign_ticket ────────────────────────────────────────────────────────

    [McpServerTool(UseStructuredContent = true)]
    [Description("Assigns a ticket to a project member by display name (case-insensitive), by id, or unassigns it when neither is provided. " +
        "Only existing project members can be assigned.")]
    public async Task<McpTicketWriteResult> AssignTicket(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("Assignee display name (project member). Omit to unassign the ticket.")] string? assignee_display_name = null,
        [Description("Assignee GUID id (alternative to assignee_display_name).")] string? assignee_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureWriteScope();
            var userId = _context.UserId;
            var current = await _resolver.ResolveTicketAsync(ticket_ref, null, userId, ct);

            string? assignee = assignee_display_name is null && assignee_id is null
                ? null
                : await ResolveAssigneeIdAsync(current.ProjectId, current.ProjectKey, assignee_display_name, assignee_id, userId, ct);

            var request = new UpdateTicketRequest(
                current.Title, current.Description, current.Type, current.Priority,
                current.StoryPoints, current.DueDate, assignee);

            var ticket = await _tickets.UpdateAsync(current.Id, userId, request, ct);
            return ToResult(ticket);
        });

    // ── move_ticket_to_sprint ───────────────────────────────────────────────

    [McpServerTool(UseStructuredContent = true)]
    [Description("Moves a ticket into a sprint of its project (by sprint name, case-insensitive, or sprint_id), " +
        "or back to the backlog when neither 'sprint_name' nor 'sprint_id' is provided. Removing a ticket from a sprint sends it to the backlog.")]
    public async Task<McpTicketWriteResult> MoveTicketToSprint(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("Sprint name within the ticket's project. Omit with sprint_id to send the ticket to the backlog.")] string? sprint_name = null,
        [Description("Sprint GUID id (alternative to sprint_name).")] string? sprint_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureWriteScope();
            var userId = _context.UserId;
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, null, userId, ct);

            Guid? sprintId = sprint_name is null && sprint_id is null
                ? null
                : await ResolveSprintIdAsync(ticket.ProjectId, ticket.ProjectKey, sprint_name, sprint_id, userId, ct);

            var updated = await _tickets.MoveToSprintAsync(ticket.Id, userId, new MoveTicketToSprintRequest(sprintId), ct);
            return ToResult(updated);
        });

    // ── add_comment ───────────────────────────────────────────────────────────

    [McpServerTool(UseStructuredContent = true)]
    [Description("Adds a comment to a ticket. The comment is attributed to the account that owns the MCP token.")]
    public async Task<McpCommentWriteResult> AddComment(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("Comment text (up to 2000 characters).")] string body,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureWriteScope();
            var userId = _context.UserId;
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, null, userId, ct);
            var comment = await _comments.CreateForTicketAsync(ticket.Id, userId, new CreateCommentRequest(body), ct);
            return new McpCommentWriteResult(ticket.TicketRef, comment.AuthorName, comment.Content, comment.CreatedAt);
        });

    // ── shared resolution ───────────────────────────────────────────────────

    private async Task<Guid?> ResolveSprintIdAsync(
        Guid projectId, string projectKey, string? sprintName, string? sprintId, string userId, CancellationToken ct)
    {
        if (sprintName is null && sprintId is null) return null;

        Disciplaner.Application.DTOs.Sprint.SprintDetailDto sprint;
        if (sprintId is not null && Guid.TryParse(sprintId, out var id))
        {
            sprint = await _sprints.GetByIdAsync(id, userId, ct)
                ?? throw new McpException(
                    $"Sprint '{sprintId}' was not found or you don't have access to its project. Use list_sprints to browse your sprints.");
        }
        else if (sprintName is not null)
        {
            var summary = await _resolver.ResolveSprintAsync(projectId, projectKey, sprintName, userId, ct);
            sprint = await _sprints.GetByIdAsync(summary.Id, userId, ct)
                ?? throw new McpException($"Sprint '{sprintName}' was not found in project {projectKey}.");
        }
        else
        {
            throw new McpException("Provide either 'sprint_name' or 'sprint_id'.");
        }

        if (sprint.ProjectId != projectId)
            throw new McpException(
                $"Sprint '{sprint.Name}' belongs to project {sprint.ProjectKey}, not to {projectKey}. " +
                "A ticket can only be planned into a sprint of its own project.");
        return sprint.Id;
    }

    private async Task<Guid?> ResolveParentIdAsync(Guid projectId, string projectKey, string? parentTicketRef, string userId, CancellationToken ct)
    {
        if (parentTicketRef is null) return null;
        var parent = await _resolver.ResolveTicketAsync(parentTicketRef, null, userId, ct);
        if (parent.ProjectId != projectId)
            throw new McpException(
                $"Parent ticket {parent.TicketRef} belongs to project {parent.ProjectKey}, not to {projectKey}. " +
                "A subtask must have a parent in the same project.");
        return parent.Id;
    }

    private async Task<string?> ResolveAssigneeIdAsync(
        Guid projectId, string projectKey, string? displayName, string? assigneeId, string userId, CancellationToken ct)
    {
        if (displayName is not null)
            return (await _resolver.ResolveMemberAsync(projectId, projectKey, displayName, userId, ct)).UserId;
        if (assigneeId is not null)
            return assigneeId;
        return null;
    }

    private McpTicketWriteResult ToResult(Disciplaner.Application.DTOs.Ticket.TicketDto ticket)
        => new(ticket.TicketRef, _context.TicketUrl(ticket.TicketRef), Projections.ToTicketDetail(ticket));
}
