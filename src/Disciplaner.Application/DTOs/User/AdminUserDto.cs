namespace Disciplaner.Application.DTOs.User;

/// <summary>Full user information visible to admins, including role.</summary>
public sealed record AdminUserDto(
    string Id,
    string DisplayName,
    string Email,
    bool IsActive,
    DateTime CreatedAt,
    IReadOnlyList<string> Roles
);
