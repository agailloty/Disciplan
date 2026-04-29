using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.DTOs.Card;
using Disciplaner.Application.DTOs.Column;
using Disciplaner.Domain.Entities;

namespace Disciplaner.Application.Mappings;

internal static class MappingExtensions
{
    internal static CardDto ToDto(this Card card) => new(
        card.Id,
        card.ColumnId,
        card.Title,
        card.Description,
        card.Order,
        card.Priority,
        card.CreatedAt,
        card.UpdatedAt,
        card.DueDate
    );

    internal static ColumnDto ToDto(this Column column) => new(
        column.Id,
        column.BoardId,
        column.Name,
        column.Order,
        column.CreatedAt,
        column.UpdatedAt,
        column.Cards.OrderBy(c => c.Order).Select(c => c.ToDto()).ToList().AsReadOnly()
    );

    internal static BoardSummaryDto ToSummaryDto(this Board board) => new(
        board.Id,
        board.Name,
        board.Description,
        board.Columns.Count,
        board.CreatedAt
    );

    internal static BoardDetailDto ToDetailDto(this Board board) => new(
        board.Id,
        board.Name,
        board.Description,
        board.OwnerId,
        board.CreatedAt,
        board.UpdatedAt,
        board.Columns.OrderBy(c => c.Order).Select(c => c.ToDto()).ToList().AsReadOnly()
    );
}
