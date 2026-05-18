namespace Disciplaner.Application.DTOs.Auth;

/// <summary>Information about a pending invitation (returned when validating a token).</summary>
public sealed record InvitationInfoResponse(
    bool IsValid,
    string? Email,       // pre-filled email, if any
    DateTime? ExpiresAt
);
