namespace Disciplaner.Application.DTOs.Attachment;

public sealed record AttachmentDto(
    Guid Id,
    string FileName,
    string ContentType,
    long SizeBytes,
    string UploadedById,
    string UploadedByName,
    DateTime UploadedAt,
    Guid? TicketId,
    Guid? CommentId,
    Guid? BoardId
);
