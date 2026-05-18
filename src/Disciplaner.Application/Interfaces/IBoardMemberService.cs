using Disciplaner.Application.DTOs.Member;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.Interfaces;

public interface IBoardMemberService
{
    Task<IReadOnlyList<MemberDto>> GetMembersAsync(Guid boardId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<MemberDto> AddMemberAsync(Guid boardId, string requestingUserId, AddMemberRequest request, CancellationToken cancellationToken = default);
    Task<MemberDto> UpdateMemberRoleAsync(Guid boardId, string targetUserId, string requestingUserId, UpdateMemberRoleRequest request, CancellationToken cancellationToken = default);
    Task RemoveMemberAsync(Guid boardId, string targetUserId, string requestingUserId, CancellationToken cancellationToken = default);
}
