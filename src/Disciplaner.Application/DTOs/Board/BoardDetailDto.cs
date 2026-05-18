using Disciplaner.Application.DTOs.Column;
using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.Member;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Board;

public sealed record BoardDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string OwnerId,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<ColumnDto> Columns,
    IReadOnlyList<LabelDto> Labels,
    IReadOnlyList<MemberDto> Members,
    MemberRole RequestingUserRole
);
