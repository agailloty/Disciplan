using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ICardRepository
{
    Task<Card?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Card>> GetByColumnIdAsync(Guid columnId, CancellationToken cancellationToken = default);
    /// <summary>Returns all cards assigned to the user that have a due date set.</summary>
    Task<IReadOnlyList<Card>> GetAssignedToUserWithDueDateAsync(string userId, CancellationToken cancellationToken = default);
    Task AddAsync(Card card, CancellationToken cancellationToken = default);
    Task UpdateAsync(Card card, CancellationToken cancellationToken = default);
    Task DeleteAsync(Card card, CancellationToken cancellationToken = default);
}
