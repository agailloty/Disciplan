using Disciplaner.Application.DTOs.Column;
using Disciplaner.Application.DTOs.Label;

namespace Disciplaner.Application.DTOs.Board;

public sealed record BoardDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string OwnerId,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<ColumnDto> Columns,
    IReadOnlyList<LabelDto> Labels
);
