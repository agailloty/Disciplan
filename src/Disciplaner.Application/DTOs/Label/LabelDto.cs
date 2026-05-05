namespace Disciplaner.Application.DTOs.Label;

public sealed record LabelDto(
    Guid Id,
    string Name,
    string Color,
    DateTime CreatedAt
);
