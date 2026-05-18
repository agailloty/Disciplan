using Disciplaner.Application.DTOs.Member;

namespace Disciplaner.Application.Interfaces;

public interface IProjectMemberService
{
    Task<IReadOnlyList<MemberDto>> GetMembersAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<MemberDto> AddMemberAsync(Guid projectId, string requestingUserId, AddMemberRequest request, CancellationToken cancellationToken = default);
    Task<MemberDto> UpdateMemberRoleAsync(Guid projectId, string targetUserId, string requestingUserId, UpdateMemberRoleRequest request, CancellationToken cancellationToken = default);
    Task RemoveMemberAsync(Guid projectId, string targetUserId, string requestingUserId, CancellationToken cancellationToken = default);
}
