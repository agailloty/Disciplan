using Disciplaner.Application.DTOs.Card;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class CardService : ICardService
{
    private readonly IUnitOfWork _uow;

    public CardService(IUnitOfWork uow)
    {
        _uow = uow;
    }

    public async Task<IReadOnlyList<CardDto>> GetByColumnAsync(
        Guid columnId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var column = await _uow.Columns.GetByIdWithCardsAsync(columnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), columnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        return column.Cards
            .OrderBy(c => c.Order)
            .Select(c => c.ToDto())
            .ToList()
            .AsReadOnly();
    }

    public async Task<CardDto?> GetByIdAsync(
        Guid cardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var card = await _uow.Cards.GetByIdAsync(cardId, cancellationToken);
        if (card is null) return null;

        var column = await _uow.Columns.GetByIdAsync(card.ColumnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), card.ColumnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        return card.ToDto();
    }

    public async Task<CardDto> CreateAsync(
        Guid columnId, string requestingUserId, CreateCardRequest request,
        CancellationToken cancellationToken = default)
    {
        var column = await _uow.Columns.GetByIdWithCardsAsync(columnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), columnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        var card = column.AddCard(request.Title, request.Description);

        if (request.Priority != card.Priority)
            card.SetPriority(request.Priority);

        if (request.DueDate.HasValue)
            card.SetDueDate(request.DueDate);

        await _uow.Columns.UpdateAsync(column, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return card.ToDto();
    }

    public async Task<CardDto> UpdateAsync(
        Guid cardId, string requestingUserId, UpdateCardRequest request,
        CancellationToken cancellationToken = default)
    {
        var card = await _uow.Cards.GetByIdAsync(cardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Card), cardId);

        var column = await _uow.Columns.GetByIdAsync(card.ColumnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), card.ColumnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        card.UpdateTitle(request.Title);
        card.UpdateDescription(request.Description);
        card.SetPriority(request.Priority);
        card.SetDueDate(request.DueDate);

        await _uow.Cards.UpdateAsync(card, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return card.ToDto();
    }

    public async Task<CardDto> MoveAsync(
        Guid cardId, string requestingUserId, MoveCardRequest request,
        CancellationToken cancellationToken = default)
    {
        var card = await _uow.Cards.GetByIdAsync(cardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Card), cardId);

        var sourceColumn = await _uow.Columns.GetByIdAsync(card.ColumnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), card.ColumnId);

        var board = await _uow.Boards.GetByIdWithColumnsAsync(sourceColumn.BoardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), sourceColumn.BoardId);

        EnsureBoardAccess(board, requestingUserId);

        board.MoveCard(cardId, request.TargetColumnId, request.TargetPosition);

        await _uow.Boards.UpdateAsync(board, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        // Reload updated card from the in-memory aggregate
        var updatedCard = board.Columns
            .SelectMany(c => c.Cards)
            .First(c => c.Id == cardId);

        return updatedCard.ToDto();
    }

    public async Task DeleteAsync(
        Guid cardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var card = await _uow.Cards.GetByIdAsync(cardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Card), cardId);

        var column = await _uow.Columns.GetByIdWithCardsAsync(card.ColumnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), card.ColumnId);

        await EnsureBoardAccessByIdAsync(column.BoardId, requestingUserId, cancellationToken);

        column.RemoveCard(cardId);

        await _uow.Columns.UpdateAsync(column, cancellationToken);
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
}
