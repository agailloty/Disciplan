namespace Disciplaner.Application.Exceptions;

/// <summary>
/// Thrown when the requesting user does not have permission to perform an action.
/// Maps to HTTP 403 in the API layer.
/// </summary>
public sealed class ForbiddenException : Exception
{
    public ForbiddenException(string? message = null)
        : base(message ?? "You do not have permission to perform this action.") { }
}
