namespace Disciplaner.Application.DTOs.User;

public sealed record UserSummaryDto(
    string Id,
    string DisplayName,
    string Email
);
