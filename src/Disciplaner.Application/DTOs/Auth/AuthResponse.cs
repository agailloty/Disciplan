namespace Disciplaner.Application.DTOs.Auth;

public sealed record AuthResponse(
    string Token,
    string Email,
    string DisplayName,
    IReadOnlyList<string> Roles,
    DateTime ExpiresAt
);
