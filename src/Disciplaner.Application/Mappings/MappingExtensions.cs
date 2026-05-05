using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.DTOs.Card;
using Disciplaner.Application.DTOs.Column;
using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Domain.Entities;

namespace Disciplaner.Application.Mappings;

internal static class MappingExtensions
{
    internal static CardDto ToDto(this Card card,
        string? createdByName = null,
        string? assigneeName = null) => new(
        card.Id,
        card.ColumnId,
        card.Title,
        card.Description,
        card.Order,
        card.Priority,
        card.CreatedAt,
        card.UpdatedAt,
        card.DueDate,
        card.CreatedById,
        createdByName,
        card.AssignedToId,
        assigneeName
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
        board.CreatedAt,
        board.Labels.Select(l => l.ToDto()).ToList().AsReadOnly()
    );

    internal static BoardDetailDto ToDetailDto(this Board board) => new(
        board.Id,
        board.Name,
        board.Description,
        board.OwnerId,
        board.CreatedAt,
        board.UpdatedAt,
        board.Columns.OrderBy(c => c.Order).Select(c => c.ToDto()).ToList().AsReadOnly(),
        board.Labels.Select(l => l.ToDto()).ToList().AsReadOnly()
    );

    internal static LabelDto ToDto(this Label l) => new(l.Id, l.Name, l.Color, l.CreatedAt);

    internal static TicketStatusDto ToDto(this TicketStatus s) =>
        new(s.Id, s.ProjectId, s.Name, s.Color, s.Order, s.Category);

    internal static SprintDto ToDto(this Sprint s, int ticketCount) =>
        new(s.Id, s.ProjectId, s.Name, s.Goal, s.Status, s.StartDate, s.EndDate, s.CreatedAt, ticketCount);

    internal static ProjectSummaryDto ToSummaryDto(this Project p, int ticketCount) =>
        new(p.Id, p.Name, p.Description, p.Key, ticketCount, p.Sprints.Count, p.CreatedAt);

    internal static ProjectDetailDto ToDetailDto(this Project p, IReadOnlyList<SprintDto> sprints) =>
        new(p.Id, p.Name, p.Description, p.Key, p.OwnerId, p.CreatedAt, p.UpdatedAt,
            p.Statuses.OrderBy(s => s.Order).Select(s => s.ToDto()).ToList().AsReadOnly(),
            sprints, p.DefaultTicketType, p.DefaultAssigneePolicy);
}
