using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Ticket;

public sealed record TicketDto(
    Guid Id,
    Guid ProjectId,
    string ProjectKey,
    int TicketNumber,
    string TicketRef,        // e.g. "DISC-42"
    string Title,
    string? Description,
    TicketType Type,
    CardPriority Priority,
    int? StoryPoints,
    DateTime? DueDate,
    TicketStatusDto Status,
    Guid? SprintId,
    string? SprintName,
    Guid? ParentTicketId,
    string? ParentTicketRef,
    string ReporterId,
    string? AssigneeId,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
