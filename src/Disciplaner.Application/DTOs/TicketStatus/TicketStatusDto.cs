using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.TicketStatus;

public sealed record TicketStatusDto(
    Guid Id,
    Guid ProjectId,
    string Name,
    string Color,
    int Order,
    StatusCategory Category
);
