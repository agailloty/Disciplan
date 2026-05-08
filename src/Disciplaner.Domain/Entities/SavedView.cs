using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Entities;

public class SavedView
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public bool IsVisibleOnHome { get; private set; } = true;
    public int DisplayOrder { get; private set; }
    public string UserId { get; private init; } = string.Empty;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    // ── Filtres ────────────────────────────────────────────────────────────────
    public Guid? ProjectId { get; private set; }
    public Guid? StatusId { get; private set; }
    public Guid? SprintId { get; private set; }
    public TicketType? Type { get; private set; }
    public CardPriority? Priority { get; private set; }
    public List<StatusCategory> StatusCategories { get; private set; } = [];
    public bool OnlyAssignedToMe { get; private set; }
    public bool OnlyReportedByMe { get; private set; }
    public bool IsCollapsedByDefault { get; private set; }

    protected SavedView() { }

    public SavedView(string name, string? description, string userId)
    {
        SetName(name);
        Description = description;
        UserId = userId;
    }

    public void Update(
        string name,
        string? description,
        bool isVisibleOnHome,
        int displayOrder,
        Guid? projectId,
        Guid? statusId,
        Guid? sprintId,
        TicketType? type,
        CardPriority? priority,
        IReadOnlyList<StatusCategory> statusCategories,
        bool onlyAssignedToMe,
        bool onlyReportedByMe,
        bool isCollapsedByDefault)
    {
        SetName(name);
        Description = description;
        IsVisibleOnHome = isVisibleOnHome;
        DisplayOrder = displayOrder;
        ProjectId = projectId;
        StatusId = statusId;
        SprintId = sprintId;
        Type = type;
        Priority = priority;
        StatusCategories = [.. statusCategories];
        OnlyAssignedToMe = onlyAssignedToMe;
        OnlyReportedByMe = onlyReportedByMe;
        IsCollapsedByDefault = isCollapsedByDefault;
        UpdatedAt = DateTime.UtcNow;
    }

    public void SetVisibility(bool isVisible)
    {
        IsVisibleOnHome = isVisible;
        UpdatedAt = DateTime.UtcNow;
    }

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Le nom de la vue ne peut pas être vide.");
        if (name.Length > DomainConstraints.SavedView.NameMaxLength)
            throw new ArgumentOutOfRangeException(nameof(name));
        Name = name;
    }
}
