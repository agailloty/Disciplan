using Disciplaner.Domain.Common;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

public class Column
{
    private readonly List<Card> _cards = [];

    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public int Order { get; private set; }
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public Guid BoardId { get; private init; }
    public Board Board { get; private init; } = null!;

    public IReadOnlyCollection<Card> Cards => _cards.AsReadOnly();

    protected Column() { }

    internal Column(string name, int order, Board board)
    {
        SetName(name);
        Order = order;
        BoardId = board.Id;
        Board = board;
    }

    public void Rename(string name)
    {
        SetName(name);
        UpdatedAt = DateTime.UtcNow;
    }

    internal void SetOrder(int order)
    {
        if (order < 0)
            throw new ColumnDomainException($"Column order must be non-negative, got {order}.");

        Order = order;
    }

    public Card AddCard(string title, string? description = null, string createdById = "")
    {
        if (_cards.Count >= DomainConstraints.Column.MaxCards)
            throw ColumnDomainException.MaxCardsReached(DomainConstraints.Column.MaxCards);

        int nextOrder = _cards.Count > 0 ? _cards.Max(c => c.Order) + 1 : 0;
        var card = new Card(title, description, nextOrder, this, createdById);
        _cards.Add(card);
        UpdatedAt = DateTime.UtcNow;
        return card;
    }

    public void RemoveCard(Guid cardId)
    {
        var card = _cards.FirstOrDefault(c => c.Id == cardId)
            ?? throw ColumnDomainException.CardNotFound(cardId);

        _cards.Remove(card);
        ReorderCards();
        UpdatedAt = DateTime.UtcNow;
    }

    public void MoveCardToPosition(Guid cardId, int targetPosition)
    {
        var card = _cards.FirstOrDefault(c => c.Id == cardId)
            ?? throw ColumnDomainException.CardNotFound(cardId);

        if (targetPosition < 0 || targetPosition >= _cards.Count)
            throw ColumnDomainException.InvalidCardPosition(targetPosition, _cards.Count);

        _cards.Remove(card);
        _cards.Insert(targetPosition, card);
        ReorderCards();
        UpdatedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Accepts an existing card moved from another column.
    /// Called exclusively by Board.MoveCard — do not call directly.
    /// </summary>
    internal void AcceptCard(Card card, int targetPosition)
    {
        if (_cards.Count >= DomainConstraints.Column.MaxCards)
            throw ColumnDomainException.MaxCardsReached(DomainConstraints.Column.MaxCards);

        int clampedPosition = Math.Clamp(targetPosition, 0, _cards.Count);
        _cards.Insert(clampedPosition, card);
        card.MoveToColumn(this);
        ReorderCards();
        UpdatedAt = DateTime.UtcNow;
    }

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw ColumnDomainException.EmptyName();

        if (name.Length > DomainConstraints.Column.NameMaxLength)
            throw ColumnDomainException.NameTooLong(DomainConstraints.Column.NameMaxLength);

        Name = name.Trim();
    }

    private void ReorderCards()
    {
        var ordered = _cards.OrderBy(c => c.Order).ToList();
        for (int i = 0; i < ordered.Count; i++)
            ordered[i].SetOrder(i);
    }
}
