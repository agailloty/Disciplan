namespace Disciplaner.Application.DTOs.Attachment;

/// <summary>Carries the raw file data from the Web layer to the Application service.</summary>
public sealed record UploadFileRequest(
    Stream Content,
    string OriginalFileName,
    string ContentType,
    long SizeBytes
);
