using Disciplaner.Application.DTOs.Card;

namespace Disciplaner.Application.DTOs.Column;

public sealed record ColumnDto(
    Guid Id,
    Guid BoardId,
    string Name,
    int Order,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<CardDto> Cards
);
