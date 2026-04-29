namespace Disciplaner.Domain.Entities;

public class Comment
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Content { get; private set; } = string.Empty;
    public string AuthorId { get; private init; } = string.Empty;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public Guid CardId { get; private init; }
    public Card Card { get; private set; } = null!;

    protected Comment() { }

    internal Comment(string content, string authorId, Card card)
    {
        SetContent(content);
        AuthorId = authorId;
        CardId = card.Id;
        Card = card;
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
}
