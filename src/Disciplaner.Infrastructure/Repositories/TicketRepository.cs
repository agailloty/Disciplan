using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class TicketRepository : ITicketRepository
{
    private readonly ApplicationDbContext _context;

    public TicketRepository(ApplicationDbContext context) => _context = context;

    public async Task<Ticket?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await IncludeDetails(_context.Tickets)
            .FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

    public async Task<IReadOnlyList<Ticket>> GetBacklogAsync(Guid projectId, CancellationToken cancellationToken = default)
        => await IncludeDetails(_context.Tickets)
            .Where(t => t.ProjectId == projectId && t.SprintId == null)
            .OrderBy(t => t.TicketNumber)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Ticket>> GetBySprintIdAsync(Guid sprintId, CancellationToken cancellationToken = default)
        => await IncludeDetails(_context.Tickets)
            .Where(t => t.SprintId == sprintId)
            .OrderBy(t => t.TicketNumber)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Ticket ticket, CancellationToken cancellationToken = default)
        => await _context.Tickets.AddAsync(ticket, cancellationToken);

    public Task UpdateAsync(Ticket ticket, CancellationToken cancellationToken = default)
    {
        _context.Tickets.Update(ticket);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Ticket ticket, CancellationToken cancellationToken = default)
    {
        _context.Tickets.Remove(ticket);
        return Task.CompletedTask;
    }

    private static IQueryable<Ticket> IncludeDetails(IQueryable<Ticket> query)
        => query
            .Include(t => t.Project)
            .Include(t => t.Status)
            .Include(t => t.Sprint)
            .Include(t => t.ParentTicket);
}
