using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Card;

public sealed record CardDto(
    Guid Id,
    Guid ColumnId,
    string Title,
    string? Description,
    int Order,
    CardPriority Priority,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    DateTime? DueDate
);
