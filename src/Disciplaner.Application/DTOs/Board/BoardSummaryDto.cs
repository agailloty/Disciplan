namespace Disciplaner.Application.DTOs.Board;

public sealed record BoardSummaryDto(
    Guid Id,
    string Name,
    string? Description,
    int ColumnCount,
    DateTime CreatedAt
);
