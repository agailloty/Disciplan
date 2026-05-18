using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class ProjectMemberService : IProjectMemberService
{
    private readonly IUnitOfWork _uow;

    public ProjectMemberService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<MemberDto>> GetMembersAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);

        if (!project.HasAccess(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' does not have access to project '{projectId}'.");

        return await ResolveMembers(project.Members, cancellationToken);
    }

    public async Task<MemberDto> AddMemberAsync(
        Guid projectId, string requestingUserId, AddMemberRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);

        if (!project.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to manage members.");

        var targetUser = await _uow.Users.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(User), request.UserId);

        var member = project.AddMember(request.UserId, request.Role);
        await _uow.ProjectMembers.AddAsync(member, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return new MemberDto(member.UserId, targetUser.DisplayName, targetUser.Email, member.Role, member.JoinedAt);
    }

    public async Task<MemberDto> UpdateMemberRoleAsync(
        Guid projectId, string targetUserId, string requestingUserId,
        UpdateMemberRoleRequest request, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);

        if (!project.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to manage members.");

        project.ChangeMemberRole(targetUserId, request.Role);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var user = await _uow.Users.GetByIdAsync(targetUserId, cancellationToken);
        var updatedMember = project.Members.First(m => m.UserId == targetUserId);
        return new MemberDto(targetUserId, user?.DisplayName ?? targetUserId, user?.Email ?? string.Empty,
            updatedMember.Role, updatedMember.JoinedAt);
    }

    public async Task RemoveMemberAsync(
        Guid projectId, string targetUserId, string requestingUserId,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);

        // Users can remove themselves; Admins can remove others
        if (targetUserId != requestingUserId && !project.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to remove members.");

        var member = await _uow.ProjectMembers.GetAsync(projectId, targetUserId, cancellationToken)
            ?? throw new NotFoundException("ProjectMember", targetUserId);

        project.RemoveMember(targetUserId);
        await _uow.ProjectMembers.DeleteAsync(member, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private async Task<IReadOnlyList<MemberDto>> ResolveMembers(
        IReadOnlyCollection<ProjectMember> members, CancellationToken cancellationToken)
    {
        var result = new List<MemberDto>(members.Count);
        foreach (var m in members)
        {
            var user = await _uow.Users.GetByIdAsync(m.UserId, cancellationToken);
            if (user is null) continue;
            result.Add(new MemberDto(m.UserId, user.DisplayName, user.Email, m.Role, m.JoinedAt));
        }
        return result.AsReadOnly();
    }
}
