using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class McpOAuthRepository : IMcpOAuthRepository
{
    private readonly ApplicationDbContext _context;

    public McpOAuthRepository(ApplicationDbContext context) => _context = context;

    public Task<McpOAuthClient?> GetClientByIdAsync(string clientId, CancellationToken cancellationToken = default)
        => _context.McpOAuthClients
            .FirstOrDefaultAsync(c => c.ClientId == clientId, cancellationToken);

    public async Task AddClientAsync(McpOAuthClient client, CancellationToken cancellationToken = default)
        => await _context.McpOAuthClients.AddAsync(client, cancellationToken);

    public Task<McpOAuthAuthorizationCode?> GetCodeByHashAsync(string codeHash, CancellationToken cancellationToken = default)
        => _context.McpOAuthAuthorizationCodes
            .FirstOrDefaultAsync(c => c.CodeHash == codeHash, cancellationToken);

    public async Task AddCodeAsync(McpOAuthAuthorizationCode code, CancellationToken cancellationToken = default)
        => await _context.McpOAuthAuthorizationCodes.AddAsync(code, cancellationToken);

    public Task<McpOAuthToken?> GetTokenByAccessHashAsync(string accessTokenHash, CancellationToken cancellationToken = default)
        => _context.McpOAuthTokens
            .FirstOrDefaultAsync(t => t.AccessTokenHash == accessTokenHash, cancellationToken);

    public Task<McpOAuthToken?> GetTokenByRefreshHashAsync(string refreshTokenHash, CancellationToken cancellationToken = default)
        => _context.McpOAuthTokens
            .FirstOrDefaultAsync(t => t.RefreshTokenHash == refreshTokenHash, cancellationToken);

    public async Task<IReadOnlyList<McpOAuthToken>> GetTokensByUserIdAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.McpOAuthTokens
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<McpOAuthToken?> GetTokenByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default)
        => _context.McpOAuthTokens
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId, cancellationToken);

    public async Task AddTokenAsync(McpOAuthToken token, CancellationToken cancellationToken = default)
        => await _context.McpOAuthTokens.AddAsync(token, cancellationToken);

    public Task UpdateTokenAsync(McpOAuthToken token, CancellationToken cancellationToken = default)
    {
        _context.McpOAuthTokens.Update(token);
        return Task.CompletedTask;
    }
}
