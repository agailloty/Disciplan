using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

public class Card
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public int Order { get; private set; }
    public CardPriority Priority { get; private set; } = CardPriority.Medium;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }
    public DateTime? DueDate { get; private set; }

    public Guid ColumnId { get; private set; }
    public Column Column { get; private set; } = null!;

    public string CreatedById { get; private init; } = string.Empty;
    public string? AssignedToId { get; private set; }

    protected Card() { }

    internal Card(string title, string? description, int order, Column column, string createdById)
    {
        SetTitle(title);
        SetDescription(description);
        Order = order;
        ColumnId = column.Id;
        Column = column;
        CreatedById = createdById;
    }

    public void UpdateTitle(string title)
    {
        SetTitle(title);
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateDescription(string? description)
    {
        SetDescription(description);
        UpdatedAt = DateTime.UtcNow;
    }

    public void Assign(string? userId)
    {
        AssignedToId = userId;
        UpdatedAt = DateTime.UtcNow;
    }

    public void SetPriority(CardPriority priority)
    {
        Priority = priority;
        UpdatedAt = DateTime.UtcNow;
    }

    public void SetDueDate(DateTime? dueDate)
    {
        if (dueDate.HasValue && dueDate.Value.Date < DateTime.UtcNow.Date)
            throw CardDomainException.DueDateInPast();

        DueDate = dueDate;
        UpdatedAt = DateTime.UtcNow;
    }

    internal void SetOrder(int order)
    {
        if (order < 0)
            throw new CardDomainException($"Card order must be non-negative, got {order}.");

        Order = order;
    }

    internal void MoveToColumn(Column column)
    {
        Column = column;
        ColumnId = column.Id;
        UpdatedAt = DateTime.UtcNow;
    }

    private void SetTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw CardDomainException.EmptyTitle();

        if (title.Length > DomainConstraints.Card.TitleMaxLength)
            throw CardDomainException.TitleTooLong(DomainConstraints.Card.TitleMaxLength);

        Title = title.Trim();
    }

    private void SetDescription(string? description)
    {
        if (description is not null && description.Length > DomainConstraints.Card.DescriptionMaxLength)
            throw CardDomainException.DescriptionTooLong(DomainConstraints.Card.DescriptionMaxLength);

        Description = description?.Trim();
    }
}
