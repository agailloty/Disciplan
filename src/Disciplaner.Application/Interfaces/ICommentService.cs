using Disciplaner.Application.DTOs.Comment;

namespace Disciplaner.Application.Interfaces;

public interface ICommentService
{
    Task<IReadOnlyList<CommentDto>> GetByCardAsync(Guid cardId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<CommentDto> CreateAsync(Guid cardId, string authorId, CreateCommentRequest request, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<CommentDto>> GetByTicketAsync(Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<CommentDto> CreateForTicketAsync(Guid ticketId, string authorId, CreateCommentRequest request, CancellationToken cancellationToken = default);
    Task<CommentDto> UpdateAsync(Guid commentId, string requestingUserId, UpdateCommentRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid commentId, string requestingUserId, bool isAdmin, CancellationToken cancellationToken = default);
}
