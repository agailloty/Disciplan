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
        if (Status == SprintStatus.Closed) throw new ArgumentException("A closed sprint cannot be edited.");
        ValidateDates(startDate, endDate);
        SetName(name);
        Goal = goal;
        StartDate = startDate;
        EndDate = endDate;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Start(DateTime startDate, DateTime endDate)
    {
        if (Status != SprintStatus.Planned) throw new ArgumentException("Only a planned sprint can start.");
        ValidateDates(startDate, endDate);
        Status = SprintStatus.Active;
        StartDate = startDate;
        EndDate = endDate;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Close()
    {
        if (Status != SprintStatus.Active) throw new ArgumentException("Only an active sprint can close.");
        Status = SprintStatus.Closed;
        UpdatedAt = DateTime.UtcNow;
    }

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Sprint name cannot be empty.");
        if (name.Length > DomainConstraints.Sprint.NameMaxLength) throw new ArgumentOutOfRangeException(nameof(name));
        Name = name;
    }

    private static void ValidateDates(DateTime? start, DateTime? end)
    {
        if (start.HasValue != end.HasValue || (start.HasValue && end <= start))
            throw new ArgumentException("Sprint dates must both be supplied, with end after start.");
    }
}
