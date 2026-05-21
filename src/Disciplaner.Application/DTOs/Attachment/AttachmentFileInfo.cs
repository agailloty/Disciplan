namespace Disciplaner.Application.DTOs.Attachment;

/// <summary>File location and metadata needed by the controller to stream a download response.</summary>
public sealed record AttachmentFileInfo(
    string AbsolutePath,
    string ContentType,
    string FileName
);
