namespace Disciplaner.Domain.Exceptions;

public sealed class BoardDomainException : DomainException
{
    public BoardDomainException(string message) : base(message) { }

    public static BoardDomainException EmptyName()
        => new("Board name cannot be empty.");

    public static BoardDomainException NameTooLong(int maxLength)
        => new($"Board name cannot exceed {maxLength} characters.");

    public static BoardDomainException DescriptionTooLong(int maxLength)
        => new($"Board description cannot exceed {maxLength} characters.");

    public static BoardDomainException MaxColumnsReached(int max)
        => new($"A board cannot have more than {max} columns.");

    public static BoardDomainException ColumnNotFound(Guid columnId)
        => new($"Column '{columnId}' does not belong to this board.");
}
