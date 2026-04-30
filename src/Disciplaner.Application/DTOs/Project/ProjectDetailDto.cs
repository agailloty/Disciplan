using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.DTOs.Sprint;

namespace Disciplaner.Application.DTOs.Project;

public sealed record ProjectDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string Key,
    string OwnerId,
    DateTime CreatedAt,
    DateTime? UpdatedAt,
    IReadOnlyList<TicketStatusDto> Statuses,
    IReadOnlyList<SprintDto> Sprints
);
