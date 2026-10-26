using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class TicketService : ITicketService
{
    private readonly IUnitOfWork _uow;

    public TicketService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<TicketDto>> GetBacklogAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureProjectAccessAsync(projectId, requestingUserId, cancellationToken);
        var tickets = await _uow.Tickets.GetBacklogAsync(projectId, cancellationToken);
        return await ToDtoListAsync(tickets, cancellationToken);
    }

    public async Task<IReadOnlyList<TicketDto>> GetBySprintAsync(
        Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var sprint = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)
            ?? throw new NotFoundException(nameof(Sprint), sprintId);
        await EnsureProjectAccessAsync(sprint.ProjectId, requestingUserId, cancellationToken);
        var tickets = await _uow.Tickets.GetBySprintIdAsync(sprintId, cancellationToken);
        return await ToDtoListAsync(tickets, cancellationToken);
    }

    public async Task<TicketDto?> GetByIdAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken);
        if (ticket is null) return null;
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);
        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task<TicketDto?> GetByRefAsync(
        string projectKey, int ticketNumber, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByRefAsync(projectKey, ticketNumber, cancellationToken);
        if (ticket is null) return null;
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);
        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task<IReadOnlyList<TicketDto>> GetAssignedToMeAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var tickets = await _uow.Tickets.GetAssignedToUserAsync(userId, cancellationToken);
        return await ToDtoListAsync(tickets, cancellationToken);
    }

    /// <summary>
    /// Filtered ticket search across the user's accessible projects (rights filtering
    /// happens in the repository query itself). Results are ordered project by project,
    /// oldest ticket first — the natural backlog order — and returned as a page
    /// with the total number of matches.
    /// </summary>
    public async Task<TicketSearchResult> SearchAsync(
        TicketSearchQuery query, string requestingUserId, CancellationToken cancellationToken = default)
    {
        // A project-scoped search behaves like the other project endpoints: access is
        // verified (403), while cross-project searches filter silently in the repository.
        if (query.ProjectId.HasValue)
            await EnsureProjectAccessAsync(query.ProjectId.Value, requestingUserId, cancellationToken);

        var (assigneeId, reporterId) = query.EffectiveUsers(requestingUserId);
        var tickets = await _uow.Tickets.GetFilteredAsync(
            requestingUserId,
            query.ProjectId,
            statusId: null,
            sprintId: query.SprintId,
            type: query.Type,
            priority: null,
            statusCategories: query.StatusCategory.HasValue ? [query.StatusCategory.Value] : null,
            assigneeId: assigneeId,
            reporterId: reporterId,
            cancellationToken);

        var dtos = await ToDtoListAsync(tickets, cancellationToken);
        var ordered = dtos
            .OrderBy(d => d.ProjectKey)
            .ThenBy(d => d.TicketNumber)
            .ToList();
        return new TicketSearchResult(
            ordered.Skip(query.EffectiveOffset).Take(query.EffectiveLimit).ToList(),
            ordered.Count);
    }

    public async Task<TicketDto> CreateAsync(
        Guid projectId, string requestingUserId, CreateTicketRequest request,
        CancellationToken cancellationToken = default)
    {
        return await _uow.InTransactionAsync(async () =>
        {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureWrite(project, requestingUserId);
        await ValidateRelationsAsync(project, request.SprintId, request.ParentTicketId, request.AssigneeId, cancellationToken);

        // Politique d'assignation par défaut du projet : à défaut d'assigné
        // explicite, le créateur reprend le ticket quand la politique l'exige.
        var assigneeId = request.AssigneeId;
        if (string.IsNullOrWhiteSpace(assigneeId) &&
            project.DefaultAssigneePolicy == DefaultAssigneePolicy.Creator)
        {
            assigneeId = requestingUserId;
        }

        var defaultStatus = project.GetDefaultStatus();
        var ticketNumber = project.ConsumeNextTicketNumber();

        var ticket = new Ticket(
            ticketNumber,
            request.Title,
            request.Description,
            request.Type,
            request.Priority,
            project,
            defaultStatus,
            requestingUserId
        );

        if (request.StoryPoints.HasValue)
            ticket.SetStoryPoints(request.StoryPoints.Value);

        if (request.DueDate.HasValue)
            ticket.SetDueDate(request.DueDate.Value);

        if (!string.IsNullOrWhiteSpace(assigneeId))
            ticket.Assign(assigneeId);

        if (request.SprintId.HasValue)
            ticket.MoveToSprint(request.SprintId.Value);

        if (request.ParentTicketId.HasValue)
            ticket.SetParent(request.ParentTicketId.Value);

        await _uow.Tickets.AddAsync(ticket, cancellationToken);
        await _uow.Projects.UpdateAsync(project, cancellationToken); // persist incremented ticketNumber

        var actorName = await GetActorNameAsync(requestingUserId, cancellationToken);
        await _uow.TicketHistory.AddAsync(
            TicketHistory.Record(ticket.Id, "created", requestingUserId, actorName,
                newValue: request.Title), cancellationToken);

        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(ticket, cancellationToken);
        }, cancellationToken);
    }

    public async Task<TicketDto> UpdateAsync(
        Guid ticketId, string requestingUserId, UpdateTicketRequest request,
        CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectWriteAsync(ticket.ProjectId, requestingUserId, cancellationToken);

        var project = await _uow.Projects.GetByIdWithMembersAsync(ticket.ProjectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), ticket.ProjectId);
        await ValidateAssigneeAsync(project, request.AssigneeId, cancellationToken);

        var actorName = await GetActorNameAsync(requestingUserId, cancellationToken);
        var history   = new List<TicketHistory>();

        if (ticket.Title != request.Title)
            history.Add(TicketHistory.Record(ticketId, "title_changed",       requestingUserId, actorName, ticket.Title,                                    request.Title));
        if (ticket.Description != request.Description)
            history.Add(TicketHistory.Record(ticketId, "description_changed", requestingUserId, actorName, ticket.Description,                              request.Description));
        if (ticket.Type != request.Type)
            history.Add(TicketHistory.Record(ticketId, "type_changed",        requestingUserId, actorName, ticket.Type.ToString(),                          request.Type.ToString()));
        if (ticket.Priority != request.Priority)
            history.Add(TicketHistory.Record(ticketId, "priority_changed",    requestingUserId, actorName, ticket.Priority.ToString(),                      request.Priority.ToString()));
        if (ticket.StoryPoints != request.StoryPoints)
            history.Add(TicketHistory.Record(ticketId, "story_points_changed",requestingUserId, actorName, ticket.StoryPoints?.ToString(),                  request.StoryPoints?.ToString()));
        if (ticket.DueDate != request.DueDate)
            history.Add(TicketHistory.Record(ticketId, "due_date_changed",    requestingUserId, actorName, ticket.DueDate?.ToString("yyyy-MM-dd"),          request.DueDate?.ToString("yyyy-MM-dd")));
        if (ticket.AssigneeId != request.AssigneeId)
            history.Add(TicketHistory.Record(ticketId, "assignee_changed",    requestingUserId, actorName, ticket.AssigneeId,                               request.AssigneeId));

        ticket.UpdateTitle(request.Title);
        ticket.UpdateDescription(request.Description);
        ticket.SetType(request.Type);
        ticket.SetPriority(request.Priority);

        ticket.SetStoryPoints(request.StoryPoints);
        ticket.SetDueDate(request.DueDate);

        ticket.Assign(request.AssigneeId);

        await _uow.Tickets.UpdateAsync(ticket, cancellationToken);
        foreach (var h in history)
            await _uow.TicketHistory.AddAsync(h, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task<TicketDto> ChangeStatusAsync(
        Guid ticketId, string requestingUserId, ChangeTicketStatusRequest request,
        CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);

        var project = await _uow.Projects.GetByIdWithDetailsAsync(ticket.ProjectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), ticket.ProjectId);
        EnsureWrite(project, requestingUserId);

        var status = project.Statuses.FirstOrDefault(s => s.Id == request.StatusId)
            ?? throw new NotFoundException(nameof(TicketStatus), request.StatusId);

        var oldStatusName = ticket.Status?.Name ?? ticket.StatusId.ToString();
        ticket.MoveToStatus(status);

        var actorName = await GetActorNameAsync(requestingUserId, cancellationToken);
        await _uow.TicketHistory.AddAsync(
            TicketHistory.Record(ticketId, "status_changed", requestingUserId, actorName,
                oldValue: oldStatusName, newValue: status.Name), cancellationToken);

        await _uow.Tickets.UpdateAsync(ticket, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task<TicketDto> MoveToSprintAsync(
        Guid ticketId, string requestingUserId, MoveTicketToSprintRequest request,
        CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectWriteAsync(ticket.ProjectId, requestingUserId, cancellationToken);

        await ValidateSprintAsync(ticket.ProjectId, request.SprintId, cancellationToken);
        var previous = ticket.SprintId;

        ticket.MoveToSprint(request.SprintId);
        if (previous != request.SprintId)
            await _uow.TicketHistory.AddAsync(TicketHistory.Record(ticket.Id, "sprint_changed", requestingUserId,
                await GetActorNameAsync(requestingUserId, cancellationToken), previous?.ToString(), request.SprintId?.ToString()), cancellationToken);
        await _uow.Tickets.UpdateAsync(ticket, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task DeleteAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectWriteAsync(ticket.ProjectId, requestingUserId, cancellationToken);

        await _uow.Tickets.DeleteAsync(ticket, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private async Task<IReadOnlyList<TicketDto>> ToDtoListAsync(IReadOnlyList<Ticket> tickets, CancellationToken ct)
    {
        // Batch-resolve unique user IDs to avoid N+1
        var userIds = tickets
            .SelectMany(t => new[] { t.ReporterId, t.AssigneeId })
            .Where(id => id is not null)
            .Select(id => id!)
            .Distinct();

        var names = new Dictionary<string, string>();
        foreach (var id in userIds)
        {
            var u = await _uow.Users.GetByIdAsync(id, ct);
            if (u is not null) names[id] = u.DisplayName;
        }

        return tickets
            .Select(t => ToDto(t,
                names.GetValueOrDefault(t.ReporterId, t.ReporterId),
                t.AssigneeId is not null ? names.GetValueOrDefault(t.AssigneeId, t.AssigneeId) : null))
            .ToList()
            .AsReadOnly();
    }

    private async Task<TicketDto> ToDtoAsync(Ticket t, CancellationToken ct)
    {
        var reporter = await _uow.Users.GetByIdAsync(t.ReporterId, ct);
        var assignee = t.AssigneeId is not null ? await _uow.Users.GetByIdAsync(t.AssigneeId, ct) : null;
        return ToDto(t, reporter?.DisplayName ?? t.ReporterId, assignee?.DisplayName);
    }

    private async Task ValidateSprintAsync(Guid projectId, Guid? sprintId, CancellationToken ct)
    {
        if (sprintId is not Guid id) return;
        var sprint = await _uow.Sprints.GetByIdAsync(id, ct);
        if (sprint is null || sprint.ProjectId != projectId || sprint.Status == Domain.Enums.SprintStatus.Closed)
            throw new ArgumentException("Sprint must be open and belong to this project.");
    }

    private async Task ValidateAssigneeAsync(Project project, string? assignee, CancellationToken ct)
    {
        if (assignee is null) return;
        var user = await _uow.Users.GetByIdAsync(assignee, ct);
        if (user is null || !user.IsActive || !project.CanWrite(assignee))
            throw new ArgumentException("Assignee must be an active contributor to this project.");
    }

    private async Task ValidateRelationsAsync(Project project, Guid? sprint, Guid? parentId, string? assignee, CancellationToken ct)
    {
        await ValidateSprintAsync(project.Id, sprint, ct);
        await ValidateAssigneeAsync(project, assignee, ct);
        var visited = new HashSet<Guid>();
        while (parentId is Guid id)
        {
            if (!visited.Add(id)) throw new ArgumentException("Parent hierarchy contains a cycle.");
            var parent = await _uow.Tickets.GetByIdAsync(id, ct);
            if (parent is null || parent.ProjectId != project.Id) throw new ArgumentException("Parent must belong to this project.");
            parentId = parent.ParentTicketId;
        }
    }

    private static void EnsureAccess(Project project, string userId)
    {
        if (!project.HasAccess(userId))
            throw new ForbiddenException($"User '{userId}' does not have access to project '{project.Id}'.");
    }

    private static void EnsureWrite(Project project, string userId)
    {
        if (!project.CanWrite(userId))
            throw new ForbiddenException($"User '{userId}' requires Member role on project '{project.Id}'.");
    }

    private async Task<Project> EnsureProjectAccessAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureAccess(project, userId);
        return project;
    }

    private async Task<Project> EnsureProjectWriteAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureWrite(project, userId);
        return project;
    }

    private async Task<string> GetActorNameAsync(string userId, CancellationToken ct)
    {
        var user = await _uow.Users.GetByIdAsync(userId, ct);
        return user?.DisplayName ?? user?.Email ?? userId;
    }

    private static TicketDto ToDto(Ticket t, string reporterName, string? assigneeName) => new(
        t.Id,
        t.ProjectId,
        t.Project?.Key ?? string.Empty,
        t.TicketNumber,
        $"{t.Project?.Key ?? "?"}-{t.TicketNumber}",
        t.Title,
        t.Description,
        t.Type,
        t.Priority,
        t.StoryPoints,
        t.DueDate,
        t.Status is not null
            ? new TicketStatusDto(t.Status.Id, t.Status.ProjectId, t.Status.Name, t.Status.Color, t.Status.Order, t.Status.Category)
            : null!,
        t.SprintId,
        t.Sprint?.Name,
        t.ParentTicketId,
        t.ParentTicket is not null ? $"{t.Project?.Key ?? "?"}-{t.ParentTicket.TicketNumber}" : null,
        t.ReporterId,
        reporterName,
        t.AssigneeId,
        assigneeName,
        t.CreatedAt,
        t.UpdatedAt,
        t.Labels.Select(l => new LabelDto(l.Id, l.Name, l.Color, l.CreatedAt)).ToList().AsReadOnly()
    );
}
