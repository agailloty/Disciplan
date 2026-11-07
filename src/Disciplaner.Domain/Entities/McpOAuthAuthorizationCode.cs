namespace Disciplaner.Domain.Entities;

/// <summary>
/// Short-lived, single-use OAuth 2.1 authorization code bound to PKCE challenge (RFC 7636).
/// Persisted with SHA-256 hash to prevent raw code exposure in database storage.
/// </summary>
public sealed class McpOAuthAuthorizationCode
{
    public Guid Id { get; private init; }

    /// <summary>Hex SHA-256 hash of the issued authorization code.</summary>
    public string CodeHash { get; private init; } = string.Empty;

    public string ClientId { get; private init; } = string.Empty;

    public string UserId { get; private init; } = string.Empty;

    public string RedirectUri { get; private init; } = string.Empty;

    public string Scope { get; private init; } = string.Empty;

    public string CodeChallenge { get; private init; } = string.Empty;

    public string CodeChallengeMethod { get; private init; } = string.Empty;

    public DateTime CreatedAt { get; private init; }

    public DateTime ExpiresAt { get; private init; }

    public DateTime? UsedAt { get; private set; }

    // Required by EF Core
    private McpOAuthAuthorizationCode() { }

    public McpOAuthAuthorizationCode(
        string codeHash,
        string clientId,
        string userId,
        string redirectUri,
        string scope,
        string codeChallenge,
        string codeChallengeMethod,
        DateTime expiresAt)
    {
        if (string.IsNullOrWhiteSpace(codeHash))
            throw new ArgumentException("CodeHash is required.", nameof(codeHash));
        if (string.IsNullOrWhiteSpace(clientId))
            throw new ArgumentException("ClientId is required.", nameof(clientId));
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("UserId is required.", nameof(userId));
        if (string.IsNullOrWhiteSpace(redirectUri))
            throw new ArgumentException("RedirectUri is required.", nameof(redirectUri));
        if (string.IsNullOrWhiteSpace(codeChallenge))
            throw new ArgumentException("CodeChallenge is required.", nameof(codeChallenge));

        Id = Guid.NewGuid();
        CodeHash = codeHash;
        ClientId = clientId.Trim();
        UserId = userId.Trim();
        RedirectUri = redirectUri.Trim();
        Scope = scope.Trim();
        CodeChallenge = codeChallenge.Trim();
        CodeChallengeMethod = string.IsNullOrWhiteSpace(codeChallengeMethod) ? "S256" : codeChallengeMethod.Trim();
        CreatedAt = DateTime.UtcNow;
        ExpiresAt = expiresAt;
    }

    public bool IsActive(DateTime utcNow) =>
        UsedAt is null && ExpiresAt > utcNow;

    public void MarkUsed(DateTime utcNow) =>
        UsedAt ??= utcNow;
}
