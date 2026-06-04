using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class CardRepository : ICardRepository
{
    private readonly ApplicationDbContext _context;

    public CardRepository(ApplicationDbContext context) => _context = context;

    public async Task<Card?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Cards.FindAsync([id], cancellationToken);

    public async Task<IReadOnlyList<Card>> GetByColumnIdAsync(Guid columnId, CancellationToken cancellationToken = default)
        => await _context.Cards
            .Where(c => c.ColumnId == columnId)
            .OrderBy(c => c.Order)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Card>> GetAssignedToUserWithDueDateAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.Cards
            .Include(c => c.Column)
                .ThenInclude(col => col!.Board)
            .Where(c => c.AssignedToId == userId && c.DueDate != null)
            .OrderBy(c => c.DueDate)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Card card, CancellationToken cancellationToken = default)
        => await _context.Cards.AddAsync(card, cancellationToken);

    public Task UpdateAsync(Card card, CancellationToken cancellationToken = default)
    {
        _context.Cards.Update(card);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Card card, CancellationToken cancellationToken = default)
    {
        _context.Cards.Remove(card);
        return Task.CompletedTask;
    }
}
