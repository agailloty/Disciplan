using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

public class Sprint
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string? Goal { get; private set; }
    public SprintStatus Status { get; private set; } = SprintStatus.Planned;
    public DateTime? StartDate { get; private set; }
    public DateTime? EndDate { get; private set; }
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public Guid ProjectId { get; private init; }
    public Project Project { get; private set; } = null!;

    protected Sprint() { }

    internal Sprint(string name, string? goal, Project project)
    {
        SetName(name);
        Goal = goal;
        ProjectId = project.Id;
        Project = project;
    }

    public void Update(string name, string? goal, DateTime? startDate, DateTime? endDate)
    {
        SetName(name);
        Goal = goal;
        StartDate = startDate;
        EndDate = endDate;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Start(DateTime startDate, DateTime endDate)
    {
        Status = SprintStatus.Active;
        StartDate = startDate;
        EndDate = endDate;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Close()
    {
        Status = SprintStatus.Closed;
        UpdatedAt = DateTime.UtcNow;
    }

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Sprint name cannot be empty.");
        if (name.Length > DomainConstraints.Sprint.NameMaxLength) throw new ArgumentOutOfRangeException(nameof(name));
        Name = name;
    }
}
