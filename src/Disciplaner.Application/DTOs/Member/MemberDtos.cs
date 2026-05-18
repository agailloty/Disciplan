using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Member;

public sealed record MemberDto(
    string UserId,
    string DisplayName,
    string Email,
    MemberRole Role,
    DateTime JoinedAt
);

public sealed record AddMemberRequest(
    string UserId,
    MemberRole Role
);

public sealed record UpdateMemberRoleRequest(
    MemberRole Role
);
