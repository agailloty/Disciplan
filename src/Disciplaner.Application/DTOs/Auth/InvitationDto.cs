namespace Disciplaner.Application.DTOs.Auth;

/// <summary>Represents an active invitation, returned to admins.</summary>
public sealed record InvitationDto(
    Guid Id,
    string Token,
    string? Email,
    string InvitedByUserId,
    DateTime CreatedAt,
    DateTime ExpiresAt,
    bool IsUsed
);
