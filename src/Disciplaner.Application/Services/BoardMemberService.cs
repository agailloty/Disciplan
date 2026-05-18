using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class BoardMemberService : IBoardMemberService
{
    private readonly IUnitOfWork _uow;

    public BoardMemberService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<MemberDto>> GetMembersAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithMembersAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        if (!board.HasAccess(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' does not have access to board '{boardId}'.");

        return await ResolveMembers(board.Members, cancellationToken);
    }

    public async Task<MemberDto> AddMemberAsync(
        Guid boardId, string requestingUserId, AddMemberRequest request,
        CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithMembersAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        if (!board.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to manage members.");

        var targetUser = await _uow.Users.GetByIdAsync(request.UserId, cancellationToken)
            ?? throw new NotFoundException(nameof(User), request.UserId);

        var member = board.AddMember(request.UserId, request.Role);
        await _uow.BoardMembers.AddAsync(member, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return new MemberDto(member.UserId, targetUser.DisplayName, targetUser.Email, member.Role, member.JoinedAt);
    }

    public async Task<MemberDto> UpdateMemberRoleAsync(
        Guid boardId, string targetUserId, string requestingUserId,
        UpdateMemberRoleRequest request, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithMembersAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        if (!board.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to manage members.");

        board.ChangeMemberRole(targetUserId, request.Role);
        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var user = await _uow.Users.GetByIdAsync(targetUserId, cancellationToken);
        var updatedMember = board.Members.First(m => m.UserId == targetUserId);
        return new MemberDto(targetUserId, user?.DisplayName ?? targetUserId, user?.Email ?? string.Empty,
            updatedMember.Role, updatedMember.JoinedAt);
    }

    public async Task RemoveMemberAsync(
        Guid boardId, string targetUserId, string requestingUserId,
        CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithMembersAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        // Users can remove themselves; Admins can remove others
        if (targetUserId != requestingUserId && !board.CanAdminister(requestingUserId))
            throw new ForbiddenException($"User '{requestingUserId}' requires Admin role to remove members.");

        var member = await _uow.BoardMembers.GetAsync(boardId, targetUserId, cancellationToken)
            ?? throw new NotFoundException("BoardMember", targetUserId);

        board.RemoveMember(targetUserId);
        await _uow.BoardMembers.DeleteAsync(member, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private async Task<IReadOnlyList<MemberDto>> ResolveMembers(
        IReadOnlyCollection<BoardMember> members, CancellationToken cancellationToken)
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
