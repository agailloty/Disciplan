using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Ticket;

public sealed record CreateTicketRequest(
    [Required, MaxLength(DomainConstraints.Ticket.TitleMaxLength)]
    string Title,
    [MaxLength(DomainConstraints.Ticket.DescriptionMaxLength)]
    string? Description,
    TicketType Type,
    CardPriority Priority,
    int? StoryPoints,
    DateTime? DueDate,
    Guid? SprintId,
    Guid? ParentTicketId,
    string? AssigneeId
);

public sealed record UpdateTicketRequest(
    [Required, MaxLength(DomainConstraints.Ticket.TitleMaxLength)]
    string Title,
    [MaxLength(DomainConstraints.Ticket.DescriptionMaxLength)]
    string? Description,
    TicketType Type,
    CardPriority Priority,
    int? StoryPoints,
    DateTime? DueDate,
    string? AssigneeId
);

public sealed record MoveTicketToSprintRequest(Guid? SprintId);
public sealed record ChangeTicketStatusRequest(Guid StatusId);
