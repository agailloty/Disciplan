namespace Disciplaner.Application.DTOs.Activity;

/// <summary>One entry in a ticket's history timeline.</summary>
public sealed record TicketHistoryEntryDto(
    Guid Id,
    string Kind,
    string? OldValue,
    string? NewValue,
    string ActorId,
    string ActorName,
    DateTime OccurredAt
);

/// <summary>Ticket activity grouped by ticket for the home-page feed.</summary>
public sealed record TicketActivityGroupDto(
    Guid TicketId,
    string TicketRef,
    string TicketTitle,
    /// <summary>Most recent event in the group.</summary>
    DateTime LastOccurredAt,
    IReadOnlyList<ActivityItemDto> Events
);
