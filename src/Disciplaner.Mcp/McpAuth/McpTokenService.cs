using Disciplaner.Application.Exceptions;
using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// Management of MCP personal access tokens: creation (raw value shown once),
/// listing and revocation. All operations are scoped to the requesting user.
/// </summary>
public sealed class McpTokenService
{
    private readonly IUnitOfWork _uow;

    public McpTokenService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<McpToken>> ListAsync(string userId, CancellationToken ct = default)
        => await _uow.McpTokens.GetByUserIdAsync(userId, ct);

    /// <summary>Persists a new token and returns its raw value — the only place it is ever exposed.</summary>
    public async Task<(McpToken Token, string RawToken)> CreateAsync(
        string userId, string name, string scopes, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Token name is required.");
        if (name.Trim().Length > DomainConstraints.McpToken.NameMaxLength)
            throw new ArgumentException($"Token name must be at most {DomainConstraints.McpToken.NameMaxLength} characters.");
        if (!McpTokenSecurity.IsValidScope(scopes))
            throw new ArgumentException($"Scopes must be '{McpTokenSecurity.ReadScope}' or '{McpTokenSecurity.ReadWriteScope}'.");

        var (raw, hash) = McpTokenSecurity.Generate();
        var token = new McpToken(userId, name, scopes, hash);
        await _uow.McpTokens.AddAsync(token, ct);
        await _uow.SaveChangesAsync(ct);
        return (token, raw);
    }

    public async Task RevokeAsync(string userId, Guid tokenId, CancellationToken ct = default)
    {
        var token = await _uow.McpTokens.GetByIdAsync(tokenId, userId, ct)
            ?? throw new NotFoundException(nameof(McpToken), tokenId);

        token.Revoke(DateTime.UtcNow);
        await _uow.McpTokens.UpdateAsync(token, ct);
        await _uow.SaveChangesAsync(ct);
    }
}
