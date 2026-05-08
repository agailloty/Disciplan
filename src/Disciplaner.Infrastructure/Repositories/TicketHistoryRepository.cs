using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class TicketHistoryRepository : ITicketHistoryRepository
{
    private readonly ApplicationDbContext _context;

    public TicketHistoryRepository(ApplicationDbContext context) => _context = context;

    public async Task<IReadOnlyList<TicketHistory>> GetByTicketAsync(
        Guid ticketId, CancellationToken cancellationToken = default)
        => await _context.TicketHistories
            .Where(h => h.TicketId == ticketId)
            .OrderBy(h => h.OccurredAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<TicketHistory>> GetRecentByUserAsync(
        string actorId, int limit, CancellationToken cancellationToken = default)
        => await _context.TicketHistories
            .Include(h => h.Ticket)
                .ThenInclude(t => t.Project)
            .Where(h => h.ActorId == actorId)
            .OrderByDescending(h => h.OccurredAt)
            .Take(limit)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(TicketHistory entry, CancellationToken cancellationToken = default)
        => await _context.TicketHistories.AddAsync(entry, cancellationToken);
}
