using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Entities;

public class Ticket
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public int TicketNumber { get; private init; }
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public TicketType Type { get; private set; } = TicketType.Story;
    public CardPriority Priority { get; private set; } = CardPriority.Medium;
    public int? StoryPoints { get; private set; }
    public DateTime? DueDate { get; private set; }
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public Guid ProjectId { get; private init; }
    public Project Project { get; private set; } = null!;

    public Guid StatusId { get; private set; }
    public TicketStatus Status { get; private set; } = null!;

    public Guid? SprintId { get; private set; }
    public Sprint? Sprint { get; private set; }

    public Guid? ParentTicketId { get; private set; }
    public Ticket? ParentTicket { get; private set; }

    public string ReporterId { get; private init; } = string.Empty;
    public string? AssigneeId { get; private set; }

    protected Ticket() { }

    public Ticket(
        int ticketNumber, string title, string? description,
        TicketType type, CardPriority priority,
        Project project, TicketStatus status, string reporterId)
    {
        TicketNumber = ticketNumber;
        SetTitle(title);
        SetDescription(description);
        Type = type;
        Priority = priority;
        ProjectId = project.Id;
        Project = project;
        StatusId = status.Id;
        Status = status;
        ReporterId = reporterId;
    }

    public void UpdateTitle(string title) { SetTitle(title); Touch(); }
    public void UpdateDescription(string? description) { SetDescription(description); Touch(); }
    public void SetType(TicketType type) { Type = type; Touch(); }
    public void SetPriority(CardPriority priority) { Priority = priority; Touch(); }
    public void SetStoryPoints(int? points) { StoryPoints = points; Touch(); }
    public void SetDueDate(DateTime? date) { DueDate = date; Touch(); }
    public void Assign(string? userId) { AssigneeId = userId; Touch(); }

    public void MoveToStatus(TicketStatus status)
    {
        StatusId = status.Id;
        Status = status;
        Touch();
    }

    public void MoveToSprint(Sprint? sprint)
    {
        SprintId = sprint?.Id;
        Sprint = sprint;
        Touch();
    }

    public void MoveToSprint(Guid? sprintId)
    {
        SprintId = sprintId;
        Sprint = null;
        Touch();
    }

    public void SetParent(Ticket? parent)
    {
        ParentTicketId = parent?.Id;
        ParentTicket = parent;
        Touch();
    }

    public void SetParent(Guid? parentTicketId)
    {
        ParentTicketId = parentTicketId;
        ParentTicket = null;
        Touch();
    }

    private void SetTitle(string title)
    {
        if (string.IsNullOrWhiteSpace(title)) throw new ArgumentException("Ticket title cannot be empty.");
        if (title.Length > DomainConstraints.Ticket.TitleMaxLength) throw new ArgumentOutOfRangeException(nameof(title));
        Title = title;
    }

    private void SetDescription(string? description)
    {
        if (description?.Length > DomainConstraints.Ticket.DescriptionMaxLength)
            throw new ArgumentOutOfRangeException(nameof(description));
        Description = description;
    }

    private void Touch() => UpdatedAt = DateTime.UtcNow;

    // ── Labels (M-N) ─────────────────────────────────────────────────────────
    private readonly List<Label> _labels = [];
    public IReadOnlyCollection<Label> Labels => _labels.AsReadOnly();
}
