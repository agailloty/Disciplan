namespace Disciplaner.Domain.Exceptions;

/// <summary>
/// Base class for all domain rule violations.
/// Thrown when a business invariant is broken — distinct from infrastructure or validation errors.
/// </summary>
public abstract class DomainException : Exception
{
    protected DomainException(string message) : base(message) { }
}
