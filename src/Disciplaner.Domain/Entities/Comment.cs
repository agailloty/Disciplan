namespace Disciplaner.Domain.Entities;

public class Comment
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Content { get; private set; } = string.Empty;
    public string AuthorId { get; private init; } = string.Empty;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    // A comment belongs to either a Card OR a Ticket (one must be set)
    public Guid? CardId { get; private init; }
    public Card? Card { get; private set; }

    public Guid? TicketId { get; private init; }
    public Ticket? Ticket { get; private set; }

    protected Comment() { }

    internal Comment(string content, string authorId, Card card)
    {
        SetContent(content);
        AuthorId = authorId;
        CardId = card.Id;
        Card = card;
    }

    internal Comment(string content, string authorId, Guid ticketId)
    {
        SetContent(content);
        AuthorId = authorId;
        TicketId = ticketId;
    }

    public void SetContent(string content)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(content);
        if (content.Length > Common.DomainConstraints.Comment.ContentMaxLength)
            throw new ArgumentOutOfRangeException(nameof(content));
        Content = content;
        UpdatedAt = DateTime.UtcNow;
    }

    public static Comment Create(string content, string authorId, Card card)
        => new(content, authorId, card);

    public static Comment CreateForTicket(string content, string authorId, Guid ticketId)
        => new(content, authorId, ticketId);
}
