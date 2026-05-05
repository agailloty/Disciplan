using Disciplaner.Domain.Common;

namespace Disciplaner.Domain.Entities;

public class Label
{
    private readonly List<Ticket> _tickets = [];
    private readonly List<Board> _boards = [];

    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string Color { get; private set; } = "#6366f1";
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;

    // EF navigation — do not use directly in app code; use LabelRepository methods
    public IReadOnlyCollection<Ticket> Tickets => _tickets.AsReadOnly();
    public IReadOnlyCollection<Board> Boards => _boards.AsReadOnly();

    protected Label() { }

    public Label(string name, string color)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Label name is required.");
        if (name.Length > DomainConstraints.Label.NameMaxLength)
            throw new ArgumentException($"Label name must be at most {DomainConstraints.Label.NameMaxLength} characters.");
        if (string.IsNullOrWhiteSpace(color))
            throw new ArgumentException("Label color is required.");
        Name = name.Trim();
        Color = color.Trim();
    }

    public void Update(string name, string color)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Label name is required.");
        if (name.Length > DomainConstraints.Label.NameMaxLength)
            throw new ArgumentException($"Label name must be at most {DomainConstraints.Label.NameMaxLength} characters.");
        if (string.IsNullOrWhiteSpace(color))
            throw new ArgumentException("Label color is required.");
        Name = name.Trim();
        Color = color.Trim();
    }

    public void AddTicket(Ticket ticket)   { if (!_tickets.Any(t => t.Id == ticket.Id)) _tickets.Add(ticket); }
    public void RemoveTicket(Ticket ticket) { _tickets.Remove(ticket); }
    public void AddBoard(Board board)       { if (!_boards.Any(b => b.Id == board.Id)) _boards.Add(board); }
    public void RemoveBoard(Board board)    { _boards.Remove(board); }
}
