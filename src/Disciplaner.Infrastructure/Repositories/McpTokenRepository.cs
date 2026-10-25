using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class McpTokenRepository : IMcpTokenRepository
{
    private readonly ApplicationDbContext _context;

    public McpTokenRepository(ApplicationDbContext context) => _context = context;

    public Task<McpToken?> GetByHashAsync(string tokenHash, CancellationToken cancellationToken = default)
        => _context.McpTokens
            .FirstOrDefaultAsync(t => t.TokenHash == tokenHash, cancellationToken);

    public async Task<IReadOnlyList<McpToken>> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.McpTokens
            .Where(t => t.UserId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<McpToken?> GetByIdAsync(Guid id, string userId, CancellationToken cancellationToken = default)
        => _context.McpTokens
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId, cancellationToken);

    public async Task AddAsync(McpToken token, CancellationToken cancellationToken = default)
        => await _context.McpTokens.AddAsync(token, cancellationToken);

    public Task UpdateAsync(McpToken token, CancellationToken cancellationToken = default)
    {
        _context.McpTokens.Update(token);
        return Task.CompletedTask;
    }
}
