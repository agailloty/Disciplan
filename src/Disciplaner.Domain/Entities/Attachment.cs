using Disciplaner.Domain.Common;

namespace Disciplaner.Domain.Entities;

public class Attachment
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string FileName { get; private init; } = string.Empty;
    public string StoragePath { get; private init; } = string.Empty;
    public string ContentType { get; private init; } = string.Empty;
    public long SizeBytes { get; private init; }
    public string UploadedById { get; private init; } = string.Empty;
    public DateTime UploadedAt { get; private init; } = DateTime.UtcNow;

    // Only one FK should be set per attachment
    public Guid? TicketId { get; private init; }
    public Guid? CommentId { get; private init; }
    public Guid? BoardId { get; private init; }

    protected Attachment() { }

    private Attachment(
        string fileName, string storagePath, string contentType,
        long sizeBytes, string uploadedById,
        Guid? ticketId, Guid? commentId, Guid? boardId)
    {
        if (string.IsNullOrWhiteSpace(fileName))
            throw new ArgumentException("File name is required.", nameof(fileName));
        if (string.IsNullOrWhiteSpace(storagePath))
            throw new ArgumentException("Storage path is required.", nameof(storagePath));
        if (string.IsNullOrWhiteSpace(contentType))
            throw new ArgumentException("Content type is required.", nameof(contentType));
        if (sizeBytes <= 0)
            throw new ArgumentOutOfRangeException(nameof(sizeBytes), "File size must be positive.");
        if (string.IsNullOrWhiteSpace(uploadedById))
            throw new ArgumentException("Uploader ID is required.", nameof(uploadedById));
        if (fileName.Length > DomainConstraints.Attachment.FileNameMaxLength)
            throw new ArgumentException($"File name must be at most {DomainConstraints.Attachment.FileNameMaxLength} characters.");

        FileName = fileName.Trim();
        StoragePath = storagePath;
        ContentType = contentType;
        SizeBytes = sizeBytes;
        UploadedById = uploadedById;
        TicketId = ticketId;
        CommentId = commentId;
        BoardId = boardId;
    }

    public static Attachment ForTicket(
        string fileName, string storagePath, string contentType, long sizeBytes,
        string uploadedById, Guid ticketId)
        => new(fileName, storagePath, contentType, sizeBytes, uploadedById, ticketId, null, null);

    public static Attachment ForComment(
        string fileName, string storagePath, string contentType, long sizeBytes,
        string uploadedById, Guid commentId)
        => new(fileName, storagePath, contentType, sizeBytes, uploadedById, null, commentId, null);

    public static Attachment ForBoard(
        string fileName, string storagePath, string contentType, long sizeBytes,
        string uploadedById, Guid boardId)
        => new(fileName, storagePath, contentType, sizeBytes, uploadedById, null, null, boardId);
}
