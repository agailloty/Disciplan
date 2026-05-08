using Disciplaner.Application.DTOs.Activity;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class TicketHistoryService : ITicketHistoryService
{
    private readonly IUnitOfWork _uow;

    public TicketHistoryService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<TicketHistoryEntryDto>> GetByTicketAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);

        // Verify access
        var project = await _uow.Projects.GetByIdAsync(ticket.ProjectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), ticket.ProjectId);
        if (project.OwnerId != requestingUserId)
            throw new UnauthorizedAccessException("Access denied.");

        var entries = await _uow.TicketHistory.GetByTicketAsync(ticketId, cancellationToken);

        return entries
            .Select(h => new TicketHistoryEntryDto(
                h.Id, h.Kind, h.OldValue, h.NewValue,
                h.ActorId, h.ActorName, h.OccurredAt))
            .ToList()
            .AsReadOnly();
    }
}
