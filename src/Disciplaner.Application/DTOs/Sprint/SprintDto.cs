using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Sprint;

public sealed record SprintDto(
    Guid Id,
    Guid ProjectId,
    string Name,
    string? Goal,
    SprintStatus Status,
    DateTime? StartDate,
    DateTime? EndDate,
    DateTime CreatedAt,
    int TicketCount
);
