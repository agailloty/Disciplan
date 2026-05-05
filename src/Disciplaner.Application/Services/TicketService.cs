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

        ticket.MoveToStatus(status);
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
