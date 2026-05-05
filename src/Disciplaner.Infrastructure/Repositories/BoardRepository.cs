using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class BoardRepository : IBoardRepository
{
    private readonly ApplicationDbContext _context;

    public BoardRepository(ApplicationDbContext context) => _context = context;

    public async Task<Board?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Boards.FindAsync([id], cancellationToken);

    public async Task<Board?> GetByIdWithColumnsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Boards
            .Include(b => b.Labels)
            .Include(b => b.Columns.OrderBy(c => c.Order))
                .ThenInclude(c => c.Cards.OrderBy(card => card.Order))
            .FirstOrDefaultAsync(b => b.Id == id, cancellationToken);

    public async Task<IReadOnlyList<Board>> GetByOwnerIdAsync(string ownerId, CancellationToken cancellationToken = default)
        => await _context.Boards
            .Include(b => b.Columns)
            .Include(b => b.Labels)
            .Where(b => b.OwnerId == ownerId)
            .OrderBy(b => b.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Board board, CancellationToken cancellationToken = default)
        => await _context.Boards.AddAsync(board, cancellationToken);

    public Task UpdateAsync(Board board, CancellationToken cancellationToken = default)
    {
        _context.Boards.Update(board);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Board board, CancellationToken cancellationToken = default)
    {
        _context.Boards.Remove(board);
        return Task.CompletedTask;
    }

    public async Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Boards.AnyAsync(b => b.Id == id, cancellationToken);
}
