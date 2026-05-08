using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ISavedViewRepository
{
    Task<SavedView?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SavedView>> GetByUserAsync(string userId, CancellationToken cancellationToken = default);
    Task AddAsync(SavedView view, CancellationToken cancellationToken = default);
    Task UpdateAsync(SavedView view, CancellationToken cancellationToken = default);
    Task DeleteAsync(SavedView view, CancellationToken cancellationToken = default);
}
