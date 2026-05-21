using Disciplaner.Application.DTOs.Attachment;

namespace Disciplaner.Application.Interfaces;

public interface IAttachmentService
{
    Task<IReadOnlyList<AttachmentDto>> GetByTicketAsync(Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttachmentDto>> GetByCommentAsync(Guid commentId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttachmentDto>> GetByBoardAsync(Guid boardId, string requestingUserId, CancellationToken cancellationToken = default);

    Task<AttachmentDto> UploadForTicketAsync(Guid ticketId, string uploadedById, UploadFileRequest file, CancellationToken cancellationToken = default);
    Task<AttachmentDto> UploadForCommentAsync(Guid commentId, string uploadedById, UploadFileRequest file, CancellationToken cancellationToken = default);
    Task<AttachmentDto> UploadForBoardAsync(Guid boardId, string uploadedById, UploadFileRequest file, CancellationToken cancellationToken = default);

    /// <summary>Resolves the file path and verifies the requesting user can access the parent entity.</summary>
    Task<AttachmentFileInfo> GetDownloadInfoAsync(Guid attachmentId, string requestingUserId, CancellationToken cancellationToken = default);

    Task DeleteAsync(Guid attachmentId, string requestingUserId, bool isAdmin, CancellationToken cancellationToken = default);
}
