namespace Disciplaner.Application.DTOs.Project;

public sealed record ProjectSummaryDto(
    Guid Id,
    string Name,
    string? Description,
    string Key,
    int TicketCount,
    int SprintCount,
    DateTime CreatedAt
);
