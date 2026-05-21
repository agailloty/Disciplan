using System.Text.RegularExpressions;
using Disciplaner.Application;
using Disciplaner.Application.Interfaces;
using Microsoft.Extensions.Options;

namespace Disciplaner.Infrastructure.Storage;

/// <summary>
/// Stores files on the local filesystem under <see cref="FileStorageOptions.BasePath"/>.
/// Files are organised as: {BasePath}/{context}/{guidPrefix}/{guid}{ext}
/// Only the relative path ({context}/{guidPrefix}/{guid}{ext}) is persisted to the database,
/// making backups fully portable — restore by pointing BasePath at the restored folder.
/// </summary>
public sealed class LocalFileStorageService : IFileStorageService
{
    private static readonly Regex SafeExtensionPattern = new(@"^\.[a-z0-9]+$", RegexOptions.Compiled);

    private readonly FileStorageOptions _options;

    public LocalFileStorageService(IOptions<FileStorageOptions> options)
        => _options = options.Value;

    public async Task<string> SaveAsync(
        Stream content, string originalFileName, string context,
        CancellationToken cancellationToken = default)
    {
        var extension = SanitizeExtension(Path.GetExtension(originalFileName));
        var id = Guid.NewGuid();
        var idHex = id.ToString("N");          // 32 hex chars, no hyphens
        var prefix = idHex[..4];               // first 4 chars for sharding
        var storageFileName = $"{idHex}{extension}";
        var relativePath = $"{context}/{prefix}/{storageFileName}";
        var absoluteDir = Path.Combine(_options.BasePath, context, prefix);
        var absolutePath = Path.Combine(absoluteDir, storageFileName);

        Directory.CreateDirectory(absoluteDir);

        await using var fileStream = new FileStream(
            absolutePath, FileMode.CreateNew, FileAccess.Write,
            FileShare.None, bufferSize: 81_920, useAsync: true);

        await content.CopyToAsync(fileStream, cancellationToken);

        return relativePath;
    }

    public Task DeleteAsync(string storagePath, CancellationToken cancellationToken = default)
    {
        var absolutePath = GetAbsolutePath(storagePath);
        if (File.Exists(absolutePath))
            File.Delete(absolutePath);
        return Task.CompletedTask;
    }

    public string GetAbsolutePath(string storagePath)
        => Path.Combine(_options.BasePath, storagePath.Replace('/', Path.DirectorySeparatorChar));

    private static string SanitizeExtension(string extension)
    {
        var lower = extension.ToLowerInvariant();
        return SafeExtensionPattern.IsMatch(lower) ? lower : string.Empty;
    }
}
