using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ICalendarTokenRepository
{
    Task<CalendarToken?> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default);
    Task<CalendarToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task AddAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default);
    Task UpdateAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default);
    Task DeleteAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default);
}
