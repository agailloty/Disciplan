namespace Disciplaner.Application.DTOs.Activity;

/// <summary>A single item in a user's activity feed.</summary>
/// <param name="Kind">
/// One of: <c>ticket_created</c>, <c>ticket_updated</c>, <c>comment_added</c>
/// </param>
public sealed record ActivityItemDto(
    string Kind,
    string Summary,
    string? TicketRef,
    Guid? TicketId,
    DateTime OccurredAt);
