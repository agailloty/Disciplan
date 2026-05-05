using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Project;

public sealed record UpdateProjectDefaultsRequest(
    TicketType DefaultTicketType,
    DefaultAssigneePolicy DefaultAssigneePolicy
);
