using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Interfaces;

public interface IBoardMemberRepository
{
    Task<BoardMember?> GetAsync(Guid boardId, string userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<BoardMember>> GetByBoardIdAsync(Guid boardId, CancellationToken cancellationToken = default);
    Task AddAsync(BoardMember member, CancellationToken cancellationToken = default);
    Task DeleteAsync(BoardMember member, CancellationToken cancellationToken = default);
}
