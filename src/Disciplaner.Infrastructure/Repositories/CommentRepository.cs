using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class CommentRepository : ICommentRepository
{
    private readonly ApplicationDbContext _context;

    public CommentRepository(ApplicationDbContext context) => _context = context;

    public async Task<Comment?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Comments.FindAsync([id], cancellationToken);

    public async Task<IReadOnlyList<Comment>> GetByCardIdAsync(Guid cardId, CancellationToken cancellationToken = default)
        => await _context.Comments
            .Where(c => c.CardId == cardId)
            .OrderBy(c => c.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Comment>> GetByTicketIdAsync(Guid ticketId, CancellationToken cancellationToken = default)
        => await _context.Comments
            .Where(c => c.TicketId == ticketId)
            .OrderBy(c => c.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Comment>> GetByAuthorAsync(string authorId, int limit, CancellationToken cancellationToken = default)
        => await _context.Comments
            .Where(c => c.AuthorId == authorId)
            .Include(c => c.Ticket)
                .ThenInclude(t => t!.Project)
            .Include(c => c.Card)
            .OrderByDescending(c => c.CreatedAt)
            .Take(limit)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Comment comment, CancellationToken cancellationToken = default)
        => await _context.Comments.AddAsync(comment, cancellationToken);

    public Task UpdateAsync(Comment comment, CancellationToken cancellationToken = default)
    {
        _context.Comments.Update(comment);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Comment comment, CancellationToken cancellationToken = default)
    {
        _context.Comments.Remove(comment);
        return Task.CompletedTask;
    }
}
