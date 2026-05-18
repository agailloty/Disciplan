using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Auth;

/// <summary>First-run setup: creates the initial admin account.</summary>
public sealed record SetupRequest(
    [Required, EmailAddress] string Email,
    [Required, MinLength(2), MaxLength(50)] string DisplayName,
    [Required, MinLength(8)] string Password
);
