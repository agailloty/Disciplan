namespace Disciplaner.Application.Exceptions;

/// <summary>
/// Thrown when a requested resource does not exist or is not visible to the caller.
/// Maps to HTTP 404 in the API layer.
/// </summary>
public sealed class NotFoundException : Exception
{
    public NotFoundException(string resourceName, object key)
        : base($"{resourceName} '{key}' was not found.") { }
}
