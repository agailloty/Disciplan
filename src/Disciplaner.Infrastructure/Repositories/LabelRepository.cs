using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class LabelRepository : ILabelRepository
{
    private readonly ApplicationDbContext _context;

    public LabelRepository(ApplicationDbContext context) => _context = context;

    public async Task<IReadOnlyList<Label>> GetAllAsync(CancellationToken cancellationToken = default)
        => await _context.Labels
            .OrderBy(l => l.Name)
            .ToListAsync(cancellationToken);

    public async Task<Label?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Labels.FindAsync([id], cancellationToken);

    public async Task<Label?> GetByIdWithItemsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Labels
            .Include(l => l.Tickets).ThenInclude(t => t.Project)
            .Include(l => l.Tickets).ThenInclude(t => t.Status)
            .Include(l => l.Boards)
            .FirstOrDefaultAsync(l => l.Id == id, cancellationToken);

    public async Task AddAsync(Label label, CancellationToken cancellationToken = default)
        => await _context.Labels.AddAsync(label, cancellationToken);

    public Task UpdateAsync(Label label, CancellationToken cancellationToken = default)
    {
        _context.Labels.Update(label);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Label label, CancellationToken cancellationToken = default)
    {
        _context.Labels.Remove(label);
        return Task.CompletedTask;
    }

    public async Task AttachToTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default)
    {
        var label = await _context.Labels
            .Include(l => l.Tickets)
            .FirstOrDefaultAsync(l => l.Id == labelId, cancellationToken);
        var ticket = await _context.Tickets.FindAsync([ticketId], cancellationToken);
        if (label is null || ticket is null) return;
        label.AddTicket(ticket);
    }

    public async Task DetachFromTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default)
    {
        var label = await _context.Labels
            .Include(l => l.Tickets)
            .FirstOrDefaultAsync(l => l.Id == labelId, cancellationToken);
        if (label is null) return;
        var ticket = label.Tickets.FirstOrDefault(t => t.Id == ticketId);
        if (ticket is not null) label.RemoveTicket(ticket);
    }

    public async Task AttachToBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default)
    {
        var label = await _context.Labels
            .Include(l => l.Boards)
            .FirstOrDefaultAsync(l => l.Id == labelId, cancellationToken);
        var board = await _context.Boards.FindAsync([boardId], cancellationToken);
        if (label is null || board is null) return;
        label.AddBoard(board);
    }

    public async Task DetachFromBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default)
    {
        var label = await _context.Labels
            .Include(l => l.Boards)
            .FirstOrDefaultAsync(l => l.Id == labelId, cancellationToken);
        if (label is null) return;
        var board = label.Boards.FirstOrDefault(b => b.Id == boardId);
        if (board is not null) label.RemoveBoard(board);
    }
}
