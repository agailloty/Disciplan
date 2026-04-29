using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Auth;

public sealed record RegisterRequest(
    [Required][EmailAddress] string Email,
    [Required][MinLength(2)][MaxLength(50)] string DisplayName,
    [Required][MinLength(8)] string Password
);
