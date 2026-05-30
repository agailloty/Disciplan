using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IAttachmentRepository
{
    Task<Attachment?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Attachment>> GetByTicketIdAsync(Guid ticketId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Attachment>> GetByCommentIdAsync(Guid commentId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Attachment>> GetByBoardIdAsync(Guid boardId, CancellationToken cancellationToken = default);
    Task AddAsync(Attachment attachment, CancellationToken cancellationToken = default);
    Task DeleteAsync(Attachment attachment, CancellationToken cancellationToken = default);
}
