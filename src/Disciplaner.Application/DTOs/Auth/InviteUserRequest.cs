using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Auth;

/// <summary>Payload for creating a user invitation link.</summary>
public sealed record InviteUserRequest(
    [EmailAddress] string? Email // optional pre-fill
);
