using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class CalendarTokenRepository : ICalendarTokenRepository
{
    private readonly ApplicationDbContext _context;

    public CalendarTokenRepository(ApplicationDbContext context) => _context = context;

    public async Task<CalendarToken?> GetByUserIdAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.CalendarTokens
            .FirstOrDefaultAsync(t => t.UserId == userId, cancellationToken);

    public async Task<CalendarToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default)
        => await _context.CalendarTokens
            .FirstOrDefaultAsync(t => t.Token == token, cancellationToken);

    public async Task AddAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default)
        => await _context.CalendarTokens.AddAsync(calendarToken, cancellationToken);

    public Task UpdateAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default)
    {
        _context.CalendarTokens.Update(calendarToken);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(CalendarToken calendarToken, CancellationToken cancellationToken = default)
    {
        _context.CalendarTokens.Remove(calendarToken);
        return Task.CompletedTask;
    }
}
