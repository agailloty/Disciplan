using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Entities;

public class TicketStatus
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string Color { get; private set; } = "#6c757d";
    public int Order { get; private set; }
    public StatusCategory Category { get; private set; } = StatusCategory.Backlog;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;

    public Guid ProjectId { get; private init; }
    public Project Project { get; private set; } = null!;

    protected TicketStatus() { }

    internal TicketStatus(string name, StatusCategory category, string color, int order, Project project)
    {
        SetName(name);
        Category = category;
        SetColor(color);
        Order = order;
        ProjectId = project.Id;
        Project = project;
    }

    internal void Update(string name, StatusCategory category, string color)
    {
        SetName(name);
        Category = category;
        SetColor(color);
    }

    internal void SetOrder(int order) => Order = order;

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Status name cannot be empty.");
        if (name.Length > DomainConstraints.TicketStatus.NameMaxLength)
            throw new ArgumentOutOfRangeException(nameof(name));
        Name = name;
    }

    private void SetColor(string color) => Color = color;
}
