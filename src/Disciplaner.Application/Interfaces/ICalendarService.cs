using Disciplaner.Application.DTOs.Calendar;

namespace Disciplaner.Application.Interfaces;

public interface ICalendarService
{
    /// <summary>Returns the current token for the user, or null if none has been generated.</summary>
    Task<CalendarTokenDto?> GetTokenAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>Creates a new token (or replaces the existing one) for the user.</summary>
    Task<CalendarTokenDto> GenerateTokenAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>Deletes the user's calendar token so the subscription URL becomes invalid.</summary>
    Task RevokeTokenAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Produces an iCalendar (RFC 5545) text feed for the given opaque token.
    /// Returns null when the token is unknown.
    /// Updates <see cref="Domain.Entities.CalendarToken.LastAccessedAt"/> as a side effect.
    /// </summary>
    Task<string?> BuildICalFeedAsync(string token, string baseUrl, CancellationToken cancellationToken = default);
}
