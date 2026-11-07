using Disciplaner.Domain.Common;

namespace Disciplaner.Domain.Entities;

/// <summary>
/// OAuth 2.1 access and refresh token pair issued to an MCP client on behalf of a user.
/// Stored via SHA-256 hashes to prevent credential leakage from database dumps.
/// </summary>
public sealed class McpOAuthToken
{
    public Guid Id { get; private init; }

    /// <summary>The client application identifier.</summary>
    public string ClientId { get; private init; } = string.Empty;

    /// <summary>Id of the user who authorized this token.</summary>
    public string UserId { get; private init; } = string.Empty;

    /// <summary>Scope granted: "read" or "read+write".</summary>
    public string Scope { get; private set; } = string.Empty;

    /// <summary>Hex SHA-256 hash of the active access token.</summary>
    public string AccessTokenHash { get; private set; } = string.Empty;

    /// <summary>Optional Hex SHA-256 hash of the refresh token.</summary>
    public string? RefreshTokenHash { get; private set; }

    public DateTime CreatedAt { get; private init; }

    public DateTime AccessTokenExpiresAt { get; private set; }

    public DateTime? RefreshTokenExpiresAt { get; private set; }

    public DateTime? LastUsedAt { get; private set; }

    public DateTime? RevokedAt { get; private set; }

    // Required by EF Core
    private McpOAuthToken() { }

    public McpOAuthToken(
        string clientId,
        string userId,
        string scope,
        string accessTokenHash,
        DateTime accessTokenExpiresAt,
        string? refreshTokenHash = null,
        DateTime? refreshTokenExpiresAt = null)
    {
        if (string.IsNullOrWhiteSpace(clientId))
            throw new ArgumentException("ClientId is required.", nameof(clientId));
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("UserId is required.", nameof(userId));
        if (!McpTokenSecurity.IsValidScope(scope))
            throw new ArgumentException($"Scope must be '{McpTokenSecurity.ReadScope}' or '{McpTokenSecurity.ReadWriteScope}'.", nameof(scope));
        if (string.IsNullOrWhiteSpace(accessTokenHash))
            throw new ArgumentException("AccessTokenHash is required.", nameof(accessTokenHash));

        Id = Guid.NewGuid();
        ClientId = clientId.Trim();
        UserId = userId.Trim();
        Scope = scope.Trim();
        AccessTokenHash = accessTokenHash;
        AccessTokenExpiresAt = accessTokenExpiresAt;
        RefreshTokenHash = string.IsNullOrWhiteSpace(refreshTokenHash) ? null : refreshTokenHash;
        RefreshTokenExpiresAt = refreshTokenExpiresAt;
        CreatedAt = DateTime.UtcNow;
    }

    public bool IsAccessTokenActive(DateTime utcNow) =>
        RevokedAt is null && AccessTokenExpiresAt > utcNow;

    public bool IsRefreshTokenActive(DateTime utcNow) =>
        RevokedAt is null && !string.IsNullOrEmpty(RefreshTokenHash) && (RefreshTokenExpiresAt is null || RefreshTokenExpiresAt > utcNow);

    public void RotateTokens(string newAccessTokenHash, DateTime newAccessTokenExpiresAt, string? newRefreshTokenHash, DateTime? newRefreshTokenExpiresAt)
    {
        AccessTokenHash = newAccessTokenHash;
        AccessTokenExpiresAt = newAccessTokenExpiresAt;
        if (!string.IsNullOrEmpty(newRefreshTokenHash))
        {
            RefreshTokenHash = newRefreshTokenHash;
            RefreshTokenExpiresAt = newRefreshTokenExpiresAt;
        }
    }

    public void RecordUse(DateTime utcNow) => LastUsedAt = utcNow;

    public void Revoke(DateTime utcNow) => RevokedAt ??= utcNow;
}
