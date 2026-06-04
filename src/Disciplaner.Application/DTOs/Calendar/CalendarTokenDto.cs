namespace Disciplaner.Application.DTOs.Calendar;

/// <summary>Returns the token info shown in the Settings page.</summary>
public sealed record CalendarTokenDto(
    string Token,
    DateTime CreatedAt,
    DateTime? LastAccessedAt
);
