using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.SavedView;

public sealed record SavedViewDto(
    Guid Id,
    string Name,
    string? Description,
    bool IsVisibleOnHome,
    int DisplayOrder,
    Guid? ProjectId,
    Guid? StatusId,
    Guid? SprintId,
    TicketType? Type,
    CardPriority? Priority,
    IReadOnlyList<StatusCategory> StatusCategories,
    bool OnlyAssignedToMe,
    bool OnlyReportedByMe,
    bool IsCollapsedByDefault,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public sealed record CreateSavedViewRequest(
    string Name,
    string? Description,
    bool IsVisibleOnHome,
    int DisplayOrder,
    Guid? ProjectId,
    Guid? StatusId,
    Guid? SprintId,
    TicketType? Type,
    CardPriority? Priority,
    IReadOnlyList<StatusCategory> StatusCategories,
    bool OnlyAssignedToMe,
    bool OnlyReportedByMe,
    bool IsCollapsedByDefault
);

public sealed record UpdateSavedViewRequest(
    string Name,
    string? Description,
    bool IsVisibleOnHome,
    int DisplayOrder,
    Guid? ProjectId,
    Guid? StatusId,
    Guid? SprintId,
    TicketType? Type,
    CardPriority? Priority,
    IReadOnlyList<StatusCategory> StatusCategories,
    bool OnlyAssignedToMe,
    bool OnlyReportedByMe,
    bool IsCollapsedByDefault
);
