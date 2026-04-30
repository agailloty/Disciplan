using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ISprintRepository
{
    Task<Sprint?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Sprint>> GetByProjectIdAsync(Guid projectId, CancellationToken cancellationToken = default);
    Task AddAsync(Sprint sprint, CancellationToken cancellationToken = default);
    Task UpdateAsync(Sprint sprint, CancellationToken cancellationToken = default);
    Task DeleteAsync(Sprint sprint, CancellationToken cancellationToken = default);
}
