using Disciplaner.Application.DTOs.Column;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class ColumnService : IColumnService
{
    private readonly IUnitOfWork _uow;

    public ColumnService(IUnitOfWork uow)
    {
        _uow = uow;
    }

    public async Task<IReadOnlyList<ColumnDto>> GetByBoardAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureBoardAccess(board, requestingUserId);

        return board.Columns
            .OrderBy(c => c.Order)
            .Select(c => c.ToDto())
            .ToList()
            .AsReadOnly();
    }

    public async Task<ColumnDto?> GetByIdAsync(
        Guid columnId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var column = await _uow.Columns.GetByIdWithCardsAsync(columnId, cancellationToken);
        if (column is null) return null;

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);
        return column.ToDto();
    }

    public async Task<ColumnDto> CreateAsync(
        Guid boardId, string requestingUserId, CreateColumnRequest request,
        CancellationToken cancellationToken = default)
    {
        var board = await _uow.Boards.GetByIdWithColumnsAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureBoardAccess(board, requestingUserId);

        var column = board.AddColumn(request.Name);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return column.ToDto();
    }

    public async Task<ColumnDto> UpdateAsync(
        Guid columnId, string requestingUserId, UpdateColumnRequest request,
        CancellationToken cancellationToken = default)
    {
        var column = await _uow.Columns.GetByIdWithCardsAsync(columnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), columnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        column.Rename(request.Name);

        await _uow.Columns.UpdateAsync(column, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return column.ToDto();
    }

    public async Task ReorderAsync(
        Guid columnId, string requestingUserId, MoveColumnRequest request,
        CancellationToken cancellationToken = default)
    {
        var board = await LoadBoardContainingColumnAsync(columnId, requestingUserId, cancellationToken);

        board.MoveColumnToPosition(columnId, request.TargetPosition);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(
        Guid columnId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var board = await LoadBoardContainingColumnAsync(columnId, requestingUserId, cancellationToken);

        board.RemoveColumn(columnId);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private static void EnsureBoardAccess(Board board, string userId)
    {
        if (board.OwnerId != userId)
            throw new ForbiddenException($"User '{userId}' does not have access to board '{board.Id}'.");
    }

    private async Task EnsureBoardAccessByIdAsync(
        Guid boardId, string userId, CancellationToken cancellationToken)
    {
        var board = await _uow.Boards.GetByIdAsync(boardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), boardId);

        EnsureBoardAccess(board, userId);
    }

    private async Task<Board> LoadBoardContainingColumnAsync(
        Guid columnId, string requestingUserId, CancellationToken cancellationToken)
    {
        var column = await _uow.Columns.GetByIdAsync(columnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), columnId);

        var board = await _uow.Boards.GetByIdWithColumnsAsync(column.BoardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), column.BoardId);

        EnsureBoardAccess(board, requestingUserId);
        return board;
    }
}
