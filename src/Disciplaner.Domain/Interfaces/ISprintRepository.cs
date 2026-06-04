using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ISprintRepository
{
    Task<Sprint?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Sprint>> GetByProjectIdAsync(Guid projectId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Sprint>> GetActiveForUserAsync(string userId, CancellationToken cancellationToken = default);
    /// <summary>Returns all sprints (any status) accessible to the user that have both StartDate and EndDate set.</summary>
    Task<IReadOnlyList<Sprint>> GetWithDatesForUserAsync(string userId, CancellationToken cancellationToken = default);
    Task AddAsync(Sprint sprint, CancellationToken cancellationToken = default);
    Task UpdateAsync(Sprint sprint, CancellationToken cancellationToken = default);
    Task DeleteAsync(Sprint sprint, CancellationToken cancellationToken = default);
}
