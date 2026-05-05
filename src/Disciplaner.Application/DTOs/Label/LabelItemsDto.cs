using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.DTOs.Ticket;

namespace Disciplaner.Application.DTOs.Label;

/// <summary>Items (tickets + boards) tagged with a given label.</summary>
public sealed record LabelItemsDto(
    LabelDto Label,
    IReadOnlyList<TicketSummaryDto> Tickets,
    IReadOnlyList<BoardSummaryDto> Boards
);

/// <summary>Lightweight ticket summary used in label results (no heavy descriptions).</summary>
public sealed record TicketSummaryDto(
    Guid Id,
    Guid ProjectId,
    string ProjectKey,
    string TicketRef,
    string Title,
    string Type,
    string Priority,
    string StatusName,
    string StatusColor
);
