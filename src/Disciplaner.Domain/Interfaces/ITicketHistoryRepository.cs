using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ITicketHistoryRepository
{
    Task<IReadOnlyList<TicketHistory>> GetByTicketAsync(
        Guid ticketId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<TicketHistory>> GetRecentByUserAsync(
        string actorId, int limit, CancellationToken cancellationToken = default);

    Task AddAsync(TicketHistory entry, CancellationToken cancellationToken = default);
}
