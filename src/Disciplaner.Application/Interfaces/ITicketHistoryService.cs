using Disciplaner.Application.DTOs.Activity;

namespace Disciplaner.Application.Interfaces;

public interface ITicketHistoryService
{
    Task<IReadOnlyList<TicketHistoryEntryDto>> GetByTicketAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default);
}
