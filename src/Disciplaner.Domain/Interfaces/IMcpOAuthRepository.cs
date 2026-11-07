using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IMcpOAuthRepository
{
    // Client management
    Task<McpOAuthClient?> GetClientByIdAsync(string clientId, CancellationToken cancellationToken = default);
    Task AddClientAsync(McpOAuthClient client, CancellationToken cancellationToken = default);

    // Authorization code management
    Task<McpOAuthAuthorizationCode?> GetCodeByHashAsync(string codeHash, CancellationToken cancellationToken = default);
    Task AddCodeAsync(McpOAuthAuthorizationCode code, CancellationToken cancellationToken = default);

    // Token management
    Task<McpOAuthToken?> GetTokenByAccessHashAsync(string accessTokenHash, CancellationToken cancellationToken = default);
    Task<McpOAuthToken?> GetTokenByRefreshHashAsync(string refreshTokenHash, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<McpOAuthToken>> GetTokensByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task<McpOAuthToken?> GetTokenByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default);
    Task AddTokenAsync(McpOAuthToken token, CancellationToken cancellationToken = default);
    Task UpdateTokenAsync(McpOAuthToken token, CancellationToken cancellationToken = default);
}
