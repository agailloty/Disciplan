namespace Disciplaner.Application.DTOs.Ticket;

/// <summary>Paged search result with the total number of matching tickets.</summary>
public sealed record TicketSearchResult(IReadOnlyList<TicketDto> Items, int TotalCount);
