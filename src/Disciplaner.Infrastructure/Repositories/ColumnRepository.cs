using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class ColumnRepository : IColumnRepository
{
    private readonly ApplicationDbContext _context;

    public ColumnRepository(ApplicationDbContext context) => _context = context;

    public async Task<Column?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Columns.FindAsync([id], cancellationToken);

    public async Task<Column?> GetByIdWithCardsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Columns
            .Include(c => c.Cards.OrderBy(card => card.Order))
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);

    public async Task<IReadOnlyList<Column>> GetByBoardIdAsync(Guid boardId, CancellationToken cancellationToken = default)
        => await _context.Columns
            .Where(c => c.BoardId == boardId)
            .OrderBy(c => c.Order)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Column column, CancellationToken cancellationToken = default)
        => await _context.Columns.AddAsync(column, cancellationToken);

    public Task UpdateAsync(Column column, CancellationToken cancellationToken = default)
    {
        _context.Columns.Update(column);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Column column, CancellationToken cancellationToken = default)
    {
        _context.Columns.Remove(column);
        return Task.CompletedTask;
    }
}
