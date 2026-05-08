using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
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

    public async Task<TicketDto> CreateAsync(
        Guid projectId, string requestingUserId, CreateTicketRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

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

        if (!string.IsNullOrWhiteSpace(request.AssigneeId))
            ticket.Assign(request.AssigneeId);

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
    }

    public async Task<TicketDto> UpdateAsync(
        Guid ticketId, string requestingUserId, UpdateTicketRequest request,
        CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);

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

        if (request.StoryPoints.HasValue)
            ticket.SetStoryPoints(request.StoryPoints.Value);

        if (request.DueDate.HasValue)
            ticket.SetDueDate(request.DueDate.Value);

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
        EnsureOwner(project, requestingUserId);

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
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);

        ticket.MoveToSprint(request.SprintId);
        await _uow.Tickets.UpdateAsync(ticket, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(ticket, cancellationToken);
    }

    public async Task DeleteAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);

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

    private static void EnsureOwner(Project project, string userId)
    {
        if (project.OwnerId != userId) throw new UnauthorizedAccessException("Access denied.");
    }

    private async Task EnsureProjectAccessAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, userId);
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
