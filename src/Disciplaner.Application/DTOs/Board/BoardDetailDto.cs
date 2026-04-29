using Disciplaner.Application.DTOs.Column;

namespace Disciplaner.Application.DTOs.Board;

public sealed record BoardDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string OwnerId,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<ColumnDto> Columns
);
