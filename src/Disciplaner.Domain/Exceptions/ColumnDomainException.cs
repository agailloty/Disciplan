namespace Disciplaner.Domain.Exceptions;

public sealed class ColumnDomainException : DomainException
{
    public ColumnDomainException(string message) : base(message) { }

    public static ColumnDomainException EmptyName()
        => new("Column name cannot be empty.");

    public static ColumnDomainException NameTooLong(int maxLength)
        => new($"Column name cannot exceed {maxLength} characters.");

    public static ColumnDomainException MaxCardsReached(int max)
        => new($"A column cannot contain more than {max} cards.");

    public static ColumnDomainException CardNotFound(Guid cardId)
        => new($"Card '{cardId}' does not belong to this column.");

    public static ColumnDomainException InvalidCardPosition(int position, int count)
        => new($"Target position {position} is out of range. Column has {count} card(s).");
}
