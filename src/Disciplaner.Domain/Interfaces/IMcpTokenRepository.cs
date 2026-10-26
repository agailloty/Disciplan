using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IMcpTokenRepository
{
    Task<McpToken?> GetByHashAsync(string tokenHash, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<McpToken>> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task<McpToken?> GetByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default);
    Task AddAsync(McpToken token, CancellationToken cancellationToken = default);
    Task UpdateAsync(McpToken token, CancellationToken cancellationToken = default);
}
