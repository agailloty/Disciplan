namespace Disciplaner.Domain.Exceptions;

public sealed class CardDomainException : DomainException
{
    public CardDomainException(string message) : base(message) { }

    public static CardDomainException EmptyTitle()
        => new("Card title cannot be empty.");

    public static CardDomainException TitleTooLong(int maxLength)
        => new($"Card title cannot exceed {maxLength} characters.");

    public static CardDomainException DescriptionTooLong(int maxLength)
        => new($"Card description cannot exceed {maxLength} characters.");

    public static CardDomainException DueDateInPast()
        => new("Card due date cannot be set to a past date.");
}
