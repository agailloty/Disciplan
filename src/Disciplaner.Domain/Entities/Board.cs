using Disciplaner.Domain.Common;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

public class Board
{
    private readonly List<Column> _columns = [];

    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public string OwnerId { get; private init; } = string.Empty;
    public User Owner { get; private init; } = null!;

    public IReadOnlyCollection<Column> Columns => _columns.AsReadOnly();

    // ── Labels (M-N) ─────────────────────────────────────────────────────────
    private readonly List<Label> _labels = [];
    public IReadOnlyCollection<Label> Labels => _labels.AsReadOnly();

    protected Board() { }

    public Board(string name, string? description, User owner)
    {
        SetName(name);
        SetDescription(description);
        OwnerId = owner.Id;
        Owner = owner;
    }

    public void Rename(string name)
    {
        SetName(name);
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateDescription(string? description)
    {
        SetDescription(description);
        UpdatedAt = DateTime.UtcNow;
    }

    public Column AddColumn(string name)
    {
        if (_columns.Count >= DomainConstraints.Board.MaxColumns)
            throw BoardDomainException.MaxColumnsReached(DomainConstraints.Board.MaxColumns);

        int nextOrder = _columns.Count > 0 ? _columns.Max(c => c.Order) + 1 : 0;
        var column = new Column(name, nextOrder, this);
        _columns.Add(column);
        UpdatedAt = DateTime.UtcNow;
        return column;
    }

    public void RemoveColumn(Guid columnId)
    {
        var column = _columns.FirstOrDefault(c => c.Id == columnId)
            ?? throw BoardDomainException.ColumnNotFound(columnId);

        _columns.Remove(column);
        ReorderColumns();
        UpdatedAt = DateTime.UtcNow;
    }

    public void MoveColumnToPosition(Guid columnId, int targetPosition)
    {
        var column = _columns.FirstOrDefault(c => c.Id == columnId)
            ?? throw BoardDomainException.ColumnNotFound(columnId);

        if (targetPosition < 0 || targetPosition >= _columns.Count)
            throw new ColumnDomainException(
                $"Target position {targetPosition} is out of range. Board has {_columns.Count} column(s).");

        _columns.Remove(column);
        _columns.Insert(targetPosition, column);
        ReorderColumns();
        UpdatedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Moves a card to a target column and position.
    /// Handles both intra-column reordering and cross-column moves.
    /// </summary>
    public void MoveCard(Guid cardId, Guid targetColumnId, int targetPosition)
    {
        var sourceColumn = _columns.FirstOrDefault(c => c.Cards.Any(card => card.Id == cardId))
            ?? throw new CardDomainException($"Card '{cardId}' was not found in any column of this board.");

        var targetColumn = _columns.FirstOrDefault(c => c.Id == targetColumnId)
            ?? throw BoardDomainException.ColumnNotFound(targetColumnId);

        if (sourceColumn.Id == targetColumn.Id)
        {
            sourceColumn.MoveCardToPosition(cardId, targetPosition);
        }
        else
        {
            var card = sourceColumn.Cards.First(c => c.Id == cardId);
            sourceColumn.RemoveCard(cardId);
            targetColumn.AcceptCard(card, targetPosition);
        }

        UpdatedAt = DateTime.UtcNow;
    }

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw BoardDomainException.EmptyName();

        if (name.Length > DomainConstraints.Board.NameMaxLength)
            throw BoardDomainException.NameTooLong(DomainConstraints.Board.NameMaxLength);

        Name = name.Trim();
    }

    private void SetDescription(string? description)
    {
        if (description is not null && description.Length > DomainConstraints.Board.DescriptionMaxLength)
            throw BoardDomainException.DescriptionTooLong(DomainConstraints.Board.DescriptionMaxLength);

        Description = description?.Trim();
    }

    private void ReorderColumns()
    {
        var ordered = _columns.OrderBy(c => c.Order).ToList();
        for (int i = 0; i < ordered.Count; i++)
            ordered[i].SetOrder(i);
    }
}
