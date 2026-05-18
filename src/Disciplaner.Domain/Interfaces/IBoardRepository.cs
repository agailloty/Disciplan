using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IBoardRepository
{
    Task<Board?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Board?> GetByIdWithColumnsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Board?> GetByIdWithMembersAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Board>> GetByOwnerIdAsync(string ownerId, CancellationToken cancellationToken = default);
    /// <summary>Returns boards owned by or where the user is an explicit member.</summary>
    Task<IReadOnlyList<Board>> GetAccessibleByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task AddAsync(Board board, CancellationToken cancellationToken = default);
    Task UpdateAsync(Board board, CancellationToken cancellationToken = default);
    Task DeleteAsync(Board board, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default);
}
