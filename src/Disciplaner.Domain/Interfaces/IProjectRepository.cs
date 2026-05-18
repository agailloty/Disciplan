using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IProjectRepository
{
    Task<Project?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Project?> GetByIdWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Project?> GetByIdWithMembersAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Project>> GetByOwnerIdAsync(string ownerId, CancellationToken cancellationToken = default);
    /// <summary>Returns projects owned by or where the user is an explicit member.</summary>
    Task<IReadOnlyList<Project>> GetAccessibleByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task<bool> KeyExistsAsync(string key, CancellationToken cancellationToken = default);
    Task AddAsync(Project project, CancellationToken cancellationToken = default);
    Task UpdateAsync(Project project, CancellationToken cancellationToken = default);
    Task DeleteAsync(Project project, CancellationToken cancellationToken = default);
    Task AddTicketStatusAsync(TicketStatus status, CancellationToken cancellationToken = default);
}
