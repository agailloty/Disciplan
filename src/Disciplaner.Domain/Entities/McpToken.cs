using Disciplaner.Domain.Common;

namespace Disciplaner.Domain.Entities;

/// <summary>
/// Personal access token used by external MCP clients (Mistral, ChatGPT, Claude Desktop, ...).
/// Acts as a bearer credential for the /mcp endpoint. Only the salted hash of the raw
/// token is persisted; the raw value is shown exactly once at creation time.
/// </summary>
public sealed class McpToken
{
    public Guid Id { get; private init; }

    /// <summary>Id of the user this token belongs to (FK to AspNetUsers.Id).</summary>
    public string UserId { get; private init; } = string.Empty;

    /// <summary>User-chosen label identifying the client using this token.</summary>
    public string Name { get; private init; } = string.Empty;

    /// <summary>Either "read" or "read+write" (see <see cref="McpTokenSecurity"/>).</summary>
    public string Scopes { get; private init; } = string.Empty;

    /// <summary>Salted SHA-256 hash of the raw token (salt embedded in the raw value itself).</summary>
    public string TokenHash { get; private init; } = string.Empty;

    public DateTime CreatedAt { get; private init; }

    public DateTime? LastUsedAt { get; private set; }

    public DateTime? RevokedAt { get; private set; }

    public DateTime? ExpiresAt { get; private init; }

    // Required by EF Core
    private McpToken() { }

    public McpToken(string userId, string name, string scopes, string tokenHash, DateTime? expiresAt = null)
    {
        if (string.IsNullOrWhiteSpace(userId)) throw new ArgumentException("UserId is required.", nameof(userId));
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Token name is required.", nameof(name));
        if (!McpTokenSecurity.IsValidScope(scopes)) throw new ArgumentException($"Scopes must be '{McpTokenSecurity.ReadScope}' or '{McpTokenSecurity.ReadWriteScope}'.", nameof(scopes));
        if (string.IsNullOrWhiteSpace(tokenHash)) throw new ArgumentException("Token hash is required.", nameof(tokenHash));

        Id = Guid.NewGuid();
        UserId = userId;
        Name = name.Trim();
        Scopes = scopes;
        TokenHash = tokenHash;
        CreatedAt = DateTime.UtcNow;
        ExpiresAt = expiresAt;
    }

    public bool IsActive(DateTime utcNow)
        => RevokedAt is null && (ExpiresAt is null || ExpiresAt > utcNow);

    public bool CanWrite => Scopes == McpTokenSecurity.ReadWriteScope;

    public void RecordUse(DateTime utcNow) => LastUsedAt = utcNow;

    public void Revoke(DateTime utcNow) => RevokedAt ??= utcNow;
}
