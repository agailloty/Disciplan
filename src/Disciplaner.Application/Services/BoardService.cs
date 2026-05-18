using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class BoardService : IBoardService
{
    private readonly IUnitOfWork _uow;

    public BoardService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<BoardSummaryDto>> GetAllByUserAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var boards = await _uow.Boards.GetAccessibleByUserIdAsync(userId, cancellationToken);
        return boards.Select(b => b.ToSummaryDto(userId)).ToList().AsReadOnly();
    }

    public async Task<BoardDetailDto?> GetByIdAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken);
        if (board is null) return null;

        EnsureAccess(board, requestingUserId);

        var members = await ResolveMembers(board.Members, cancellationToken);

        // Resolve creator names for all cards in one pass
        var creatorIds = board.Columns
            .SelectMany(c => c.Cards)
            .Select(c => c.CreatedById)
            .Where(id => !string.IsNullOrEmpty(id))
            .Distinct()
            .ToList();

        var nameMap = new Dictionary<string, string>();
        foreach (var id in creatorIds)
        {
            var user = await _uow.Users.GetByIdAsync(id, cancellationToken);
            if (user is not null)
                nameMap[id] = !string.IsNullOrWhiteSpace(user.DisplayName) ? user.DisplayName : user.UserName;
        }

        var columns = board.Columns.OrderBy(c => c.Order).Select(col =>
        {
            var cards = col.Cards.OrderBy(c => c.Order)
                .Select(c => c.ToDto(
                    nameMap.TryGetValue(c.CreatedById, out var n) ? n : null,
                    null))
                .ToList().AsReadOnly();
            return col.ToDto() with { Cards = cards };
        }).ToList().AsReadOnly();

        return board.ToDetailDto(requestingUserId, members) with { Columns = columns };
    }

    public async Task<BoardDetailDto> CreateAsync(
        string ownerId, CreateBoardRequest request, CancellationToken cancellationToken = default)
    {
        var owner = await _uow.Users.GetByIdAsync(ownerId, cancellationToken)
            ?? throw new NotFoundException(nameof(User), ownerId);

        var board = new Board(request.Name, request.Description, owner);
        await _uow.Boards.AddAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return board.ToDetailDto(ownerId, []);
    }

    public async Task<BoardDetailDto> UpdateAsync(
        Guid boardId, string requestingUserId, UpdateBoardRequest request,
        CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureAdmin(board, requestingUserId);

        board.Rename(request.Name);
        board.UpdateDescription(request.Description);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var members = await ResolveMembers(board.Members, cancellationToken);
        return board.ToDetailDto(requestingUserId, members);
    }

    public async Task DeleteAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureAdmin(board, requestingUserId);

        await _uow.Boards.DeleteAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static void EnsureAccess(Board board, string userId)
    {
        if (!board.HasAccess(userId))
            throw new ForbiddenException($"User '{userId}' does not have access to board '{board.Id}'.");
    }

    private static void EnsureAdmin(Board board, string userId)
    {
        if (!board.CanAdminister(userId))
            throw new ForbiddenException($"User '{userId}' requires Admin role on board '{board.Id}'.");
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
