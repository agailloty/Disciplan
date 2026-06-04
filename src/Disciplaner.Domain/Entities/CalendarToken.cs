namespace Disciplaner.Domain.Entities;

/// <summary>
/// Opaque subscription token that grants read-only access to a user's calendar feed.
/// Acts as a bearer secret: anyone who holds the token can read the feed.
/// </summary>
public sealed class CalendarToken
{
    public Guid Id { get; private init; }

    /// <summary>Id of the user this token belongs to (FK to AspNetUsers.Id).</summary>
    public string UserId { get; private init; } = string.Empty;

    /// <summary>
    /// URL-safe random token included in the iCal subscription URL.
    /// Generated as a cryptographically random value — 40 hex chars.
    /// </summary>
    public string Token { get; private init; } = string.Empty;

    public DateTime CreatedAt { get; private init; }

    /// <summary>Tracks when the feed was last fetched by an external calendar client.</summary>
    public DateTime? LastAccessedAt { get; private set; }

    // Required by EF Core
    private CalendarToken() { }

    public CalendarToken(string userId)
    {
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("UserId is required.", nameof(userId));

        Id = Guid.NewGuid();
        UserId = userId;
        Token = GenerateToken();
        CreatedAt = DateTime.UtcNow;
    }

    public void RecordAccess() => LastAccessedAt = DateTime.UtcNow;

    /// <summary>Generates a new token value while keeping the same record (effectively revoke + replace).</summary>
    public CalendarToken Regenerate(string userId) => new(userId);

    private static string GenerateToken()
    {
        var bytes = new byte[20];
        System.Security.Cryptography.RandomNumberGenerator.Fill(bytes);
        return Convert.ToHexString(bytes).ToLowerInvariant(); // 40-char hex, URL-safe
    }
}
