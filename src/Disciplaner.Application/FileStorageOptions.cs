namespace Disciplaner.Application;

public sealed class FileStorageOptions
{
    public const string SectionName = "FileStorage";

    /// <summary>Root directory where uploaded files are stored. Should match the Docker volume mount.</summary>
    public string BasePath { get; set; } = "/data/uploads";

    /// <summary>Maximum allowed file size in bytes. Default: 50 MB.</summary>
    public long MaxFileSizeBytes { get; set; } = 52_428_800;

    /// <summary>Maximum allowed profile picture size in bytes. Default: 5 MB.</summary>
    public long MaxProfilePictureSizeBytes { get; set; } = 5_242_880;

    /// <summary>MIME types accepted for general attachments (tickets, comments, boards).</summary>
    public string[] AllowedContentTypes { get; set; } =
    [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.ms-powerpoint",
        "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        "text/plain",
        "text/csv",
        "application/zip",
        "application/x-zip-compressed",
    ];

    /// <summary>MIME types accepted for profile pictures.</summary>
    public string[] AllowedProfilePictureContentTypes { get; set; } =
    [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
    ];
}
