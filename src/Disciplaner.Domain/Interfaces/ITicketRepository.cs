using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ITicketRepository
{
    Task<Ticket?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Ticket?> GetByRefAsync(string projectKey, int ticketNumber, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Ticket>> GetBacklogAsync(Guid projectId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Ticket>> GetBySprintIdAsync(Guid sprintId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Ticket>> GetAssignedToUserAsync(string userId, CancellationToken cancellationToken = default);
    Task AddAsync(Ticket ticket, CancellationToken cancellationToken = default);
    Task UpdateAsync(Ticket ticket, CancellationToken cancellationToken = default);
    Task DeleteAsync(Ticket ticket, CancellationToken cancellationToken = default);
}
