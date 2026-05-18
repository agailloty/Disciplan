using Disciplaner.Application.DTOs.Label;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Board;

public sealed record BoardSummaryDto(
    Guid Id,
    string Name,
    string? Description,
    int ColumnCount,
    DateTime CreatedAt,
    IReadOnlyList<LabelDto> Labels,
    MemberRole RequestingUserRole,
    bool IsOwner
);
