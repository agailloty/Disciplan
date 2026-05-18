using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Project;

public sealed record ProjectDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string Key,
    string OwnerId,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<TicketStatusDto> Statuses,
    IReadOnlyList<SprintDto> Sprints,
    TicketType DefaultTicketType,
    DefaultAssigneePolicy DefaultAssigneePolicy,
    IReadOnlyList<MemberDto> Members,
    MemberRole RequestingUserRole
);
