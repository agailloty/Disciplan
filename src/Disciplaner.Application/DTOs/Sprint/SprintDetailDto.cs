using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Sprint;

public sealed record SprintDetailDto(
    Guid Id,
    Guid ProjectId,
    string ProjectName,
    string ProjectKey,
    string Name,
    string? Goal,
    SprintStatus Status,
    DateTime? StartDate,
    DateTime? EndDate,
    DateTime CreatedAt,
    IReadOnlyList<TicketStatusDto> Statuses
);
