using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Auth;

/// <summary>Registration via an invitation token.</summary>
public sealed record InvitationRegisterRequest(
    [Required] string Token,
    [Required, EmailAddress] string Email,
    [Required, MinLength(2), MaxLength(50)] string DisplayName,
    [Required, MinLength(8)] string Password
);
