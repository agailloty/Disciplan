using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class BoardMemberRepository : IBoardMemberRepository
{
    private readonly ApplicationDbContext _context;

    public BoardMemberRepository(ApplicationDbContext context) => _context = context;

    public async Task<BoardMember?> GetAsync(Guid boardId, string userId, CancellationToken cancellationToken = default)
        => await _context.BoardMembers
            .FirstOrDefaultAsync(m => m.BoardId == boardId && m.UserId == userId, cancellationToken);

    public async Task<IReadOnlyList<BoardMember>> GetByBoardIdAsync(Guid boardId, CancellationToken cancellationToken = default)
        => await _context.BoardMembers
            .Where(m => m.BoardId == boardId)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(BoardMember member, CancellationToken cancellationToken = default)
        => await _context.BoardMembers.AddAsync(member, cancellationToken);

    public Task DeleteAsync(BoardMember member, CancellationToken cancellationToken = default)
    {
        _context.BoardMembers.Remove(member);
        return Task.CompletedTask;
    }
}
