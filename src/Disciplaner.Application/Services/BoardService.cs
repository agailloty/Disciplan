using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class BoardService : IBoardService
{
    private readonly IUnitOfWork _uow;

    public BoardService(IUnitOfWork uow)
    {
        _uow = uow;
    }

    public async Task<IReadOnlyList<BoardSummaryDto>> GetAllByUserAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var boards = await _uow.Boards.GetByOwnerIdAsync(userId, cancellationToken);
        return boards.Select(b => b.ToSummaryDto()).ToList().AsReadOnly();
    }

    public async Task<BoardDetailDto?> GetByIdAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken);
        if (board is null) return null;

        EnsureOwner(board, requestingUserId);
        return board.ToDetailDto();
    }

    public async Task<BoardDetailDto> CreateAsync(
        string ownerId, CreateBoardRequest request, CancellationToken cancellationToken = default)
    {
        var owner = await _uow.Users.GetByIdAsync(ownerId, cancellationToken)
            ?? throw new NotFoundException(nameof(User), ownerId);

        var board = new Board(request.Name, request.Description, owner);
        await _uow.Boards.AddAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return board.ToDetailDto();
    }

    public async Task<BoardDetailDto> UpdateAsync(
        Guid boardId, string requestingUserId, UpdateBoardRequest request,
        CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureOwner(board, requestingUserId);

        board.Rename(request.Name);
        board.UpdateDescription(request.Description);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return board.ToDetailDto();
    }

    public async Task DeleteAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureOwner(board, requestingUserId);

        await _uow.Boards.DeleteAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private static void EnsureOwner(Board board, string userId)
    {
        if (board.OwnerId != userId)
            throw new ForbiddenException($"User '{userId}' does not own board '{board.Id}'.");
    }
}
