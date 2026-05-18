using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.User;

/// <summary>Payload for admin creating a user directly (without invitation).</summary>
public sealed record CreateUserRequest(
    [Required, EmailAddress] string Email,
    [Required, MinLength(2), MaxLength(50)] string DisplayName,
    [Required, MinLength(8)] string Password,
    [Required] string Role
);
