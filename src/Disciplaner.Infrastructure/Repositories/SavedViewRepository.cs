using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class SavedViewRepository : ISavedViewRepository
{
    private readonly ApplicationDbContext _context;

    public SavedViewRepository(ApplicationDbContext context) => _context = context;

    public async Task<SavedView?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.SavedViews.FirstOrDefaultAsync(v => v.Id == id, cancellationToken);

    public async Task<IReadOnlyList<SavedView>> GetByUserAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.SavedViews
            .Where(v => v.UserId == userId)
            .OrderBy(v => v.DisplayOrder)
            .ThenBy(v => v.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(SavedView view, CancellationToken cancellationToken = default)
        => await _context.SavedViews.AddAsync(view, cancellationToken);

    public Task UpdateAsync(SavedView view, CancellationToken cancellationToken = default)
    {
        _context.SavedViews.Update(view);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(SavedView view, CancellationToken cancellationToken = default)
    {
        _context.SavedViews.Remove(view);
        return Task.CompletedTask;
    }
}
