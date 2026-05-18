namespace Disciplaner.Domain.Entities;

/// <summary>
/// Represents an invitation sent by an admin to allow a new user to create an account.
/// </summary>
public sealed class UserInvitation
{
    public Guid Id { get; private init; }

    /// <summary>Opaque URL-safe token included in the invitation link.</summary>
    public string Token { get; private init; } = string.Empty;

    /// <summary>Optional pre-filled email address for the invitee.</summary>
    public string? Email { get; private init; }

    /// <summary>Id of the admin user who created the invitation.</summary>
    public string InvitedByUserId { get; private init; } = string.Empty;

    public DateTime CreatedAt { get; private init; }
    public DateTime ExpiresAt { get; private init; }

    public bool IsUsed { get; private set; }
    public string? UsedByUserId { get; private set; }
    public DateTime? UsedAt { get; private set; }

    // Required by EF Core
    private UserInvitation() { }

    public UserInvitation(string? email, string invitedByUserId, TimeSpan? validFor = null)
    {
        if (string.IsNullOrWhiteSpace(invitedByUserId))
            throw new ArgumentException("InvitedByUserId is required.", nameof(invitedByUserId));

        Id = Guid.NewGuid();
        Token = Guid.NewGuid().ToString("N"); // 32-char hex, URL-safe
        Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim().ToLowerInvariant();
        InvitedByUserId = invitedByUserId;
        CreatedAt = DateTime.UtcNow;
        ExpiresAt = DateTime.UtcNow.Add(validFor ?? TimeSpan.FromDays(7));
    }

    public bool IsExpired => DateTime.UtcNow > ExpiresAt;
    public bool IsValid => !IsUsed && !IsExpired;

    public void MarkUsed(string userId)
    {
        if (string.IsNullOrWhiteSpace(userId))
            throw new ArgumentException("UserId is required.", nameof(userId));

        IsUsed = true;
        UsedByUserId = userId;
        UsedAt = DateTime.UtcNow;
    }
}
