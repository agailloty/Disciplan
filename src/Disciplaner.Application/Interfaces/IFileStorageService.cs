namespace Disciplaner.Application.Interfaces;

/// <summary>
/// Abstracts file persistence. The infrastructure layer provides the local filesystem implementation.
/// Paths returned are always relative to the configured BasePath so they are portable across environments.
/// </summary>
public interface IFileStorageService
{
    /// <summary>
    /// Persists <paramref name="content"/> to storage under the given <paramref name="context"/> folder
    /// (e.g. "tickets", "boards", "profiles") and returns the relative storage path.
    /// </summary>
    Task<string> SaveAsync(Stream content, string originalFileName, string context, CancellationToken cancellationToken = default);

    /// <summary>Deletes the file at <paramref name="storagePath"/> (relative). No-op if the file does not exist.</summary>
    Task DeleteAsync(string storagePath, CancellationToken cancellationToken = default);

    /// <summary>Resolves a relative <paramref name="storagePath"/> to an absolute filesystem path.</summary>
    string GetAbsolutePath(string storagePath);
}
