using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

public class Project
{
    private readonly List<TicketStatus> _statuses = [];
    private readonly List<Sprint> _sprints = [];
    private readonly List<ProjectMember> _members = [];
    private int _nextTicketNumber = 1;

    public Guid Id { get; private init; } = Guid.NewGuid();
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public string Key { get; private set; } = string.Empty; // e.g. "DISC"
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; private set; }

    public TicketType DefaultTicketType { get; private set; } = TicketType.Story;
    public DefaultAssigneePolicy DefaultAssigneePolicy { get; private set; } = DefaultAssigneePolicy.None;

    public string OwnerId { get; private init; } = string.Empty;
    public User Owner { get; private init; } = null!;

    public IReadOnlyCollection<TicketStatus> Statuses => _statuses.AsReadOnly();
    public IReadOnlyCollection<Sprint> Sprints => _sprints.AsReadOnly();
    public IReadOnlyCollection<ProjectMember> Members => _members.AsReadOnly();

    protected Project() { }

    // ── Membership ────────────────────────────────────────────────────────────

    /// <summary>Returns the effective role of a user: Admin if owner, otherwise their membership role, null if not a member.</summary>
    public MemberRole? GetEffectiveRole(string userId)
    {
        if (OwnerId == userId) return MemberRole.Admin;
        return _members.FirstOrDefault(m => m.UserId == userId)?.Role;
    }

    public bool HasAccess(string userId) => GetEffectiveRole(userId).HasValue;
    public bool CanWrite(string userId) => GetEffectiveRole(userId) >= MemberRole.Member;
    public bool CanManage(string userId) => GetEffectiveRole(userId) >= MemberRole.Supervisor;
    public bool CanAdminister(string userId) => GetEffectiveRole(userId) >= MemberRole.Admin;

    public ProjectMember AddMember(string userId, MemberRole role)
    {
        if (OwnerId == userId)
            throw MembershipDomainException.CannotModifyOwner(userId);

        if (role == MemberRole.Admin)
            throw MembershipDomainException.CannotAssignRoleAboveSupervisor();

        if (_members.Any(m => m.UserId == userId))
            throw MembershipDomainException.AlreadyMember(userId, Id.ToString());

        var member = new ProjectMember(Id, userId, role);
        _members.Add(member);
        Touch();
        return member;
    }

    public void ChangeMemberRole(string userId, MemberRole newRole)
    {
        if (OwnerId == userId)
            throw MembershipDomainException.CannotModifyOwner(userId);

        if (newRole == MemberRole.Admin)
            throw MembershipDomainException.CannotAssignRoleAboveSupervisor();

        var member = _members.FirstOrDefault(m => m.UserId == userId)
            ?? throw MembershipDomainException.MemberNotFound(userId, Id.ToString());

        member.ChangeRole(newRole);
        Touch();
    }

    public void RemoveMember(string userId)
    {
        if (OwnerId == userId)
            throw MembershipDomainException.CannotModifyOwner(userId);

        var member = _members.FirstOrDefault(m => m.UserId == userId)
            ?? throw MembershipDomainException.MemberNotFound(userId, Id.ToString());

        _members.Remove(member);
        Touch();
    }

    public Project(string name, string? description, string key, User owner)
    {
        SetName(name);
        SetDescription(description);
        SetKey(key);
        OwnerId = owner.Id;
        Owner = owner;

        // Seed default statuses
        _statuses.Add(new TicketStatus("To Do",       StatusCategory.Backlog,     "#6c757d", 0, this));
        _statuses.Add(new TicketStatus("In Progress",  StatusCategory.InProgress,  "#0d6efd", 1, this));
        _statuses.Add(new TicketStatus("Done",         StatusCategory.Done,        "#198754", 2, this));
    }

    // ── Metadata ──────────────────────────────────────────────────────────────

    public void Rename(string name) { SetName(name); Touch(); }
    public void UpdateDescription(string? description) { SetDescription(description); Touch(); }

    public void UpdateDefaults(TicketType defaultTicketType, DefaultAssigneePolicy defaultAssigneePolicy)
    {
        DefaultTicketType = defaultTicketType;
        DefaultAssigneePolicy = defaultAssigneePolicy;
        Touch();
    }

    // ── Ticket numbering ──────────────────────────────────────────────────────

    public int ConsumeNextTicketNumber()
    {
        var n = _nextTicketNumber;
        _nextTicketNumber++;
        Touch();
        return n;
    }

    // ── Statuses ──────────────────────────────────────────────────────────────

    public TicketStatus AddStatus(string name, StatusCategory category, string color)
    {
        int order = _statuses.Count > 0 ? _statuses.Max(s => s.Order) + 1 : 0;
        var status = new TicketStatus(name, category, color, order, this);
        _statuses.Add(status);
        Touch();
        return status;
    }

    public void UpdateStatus(Guid statusId, string name, StatusCategory category, string color)
    {
        var status = _statuses.FirstOrDefault(s => s.Id == statusId)
            ?? throw ProjectDomainException.StatusNotFound(statusId);
        status.Update(name, category, color);
        Touch();
    }

    public void RemoveStatus(Guid statusId)
    {
        if (_statuses.Count <= 1) throw ProjectDomainException.DefaultStatusRequired();
        var status = _statuses.FirstOrDefault(s => s.Id == statusId)
            ?? throw ProjectDomainException.StatusNotFound(statusId);
        _statuses.Remove(status);
        ReorderStatuses();
        Touch();
    }

    public TicketStatus GetDefaultStatus()
        => _statuses.OrderBy(s => s.Order).First();

    // ── Sprints ───────────────────────────────────────────────────────────────

    public Sprint AddSprint(string name, string? goal)
    {
        var sprint = new Sprint(name, goal, this);
        _sprints.Add(sprint);
        Touch();
        return sprint;
    }

    public void StartSprint(Guid sprintId, DateTime startDate, DateTime endDate)
    {
        var activeExists = _sprints.Any(s => s.Status == SprintStatus.Active);
        if (activeExists)
        {
            var activeName = _sprints.First(s => s.Status == SprintStatus.Active).Name;
            throw ProjectDomainException.SprintAlreadyActive(activeName);
        }

        var sprint = _sprints.FirstOrDefault(s => s.Id == sprintId)
            ?? throw ProjectDomainException.SprintNotFound(sprintId);

        sprint.Start(startDate, endDate);
        Touch();
    }

    public void CloseSprint(Guid sprintId)
    {
        var sprint = _sprints.FirstOrDefault(s => s.Id == sprintId)
            ?? throw ProjectDomainException.SprintNotFound(sprintId);
        sprint.Close();
        Touch();
    }

    // ── Private ───────────────────────────────────────────────────────────────

    private void SetName(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) throw ProjectDomainException.EmptyName();
        if (name.Length > DomainConstraints.Project.NameMaxLength) throw ProjectDomainException.NameTooLong(DomainConstraints.Project.NameMaxLength);
        Name = name;
    }

    private void SetDescription(string? description)
    {
        if (description?.Length > DomainConstraints.Project.DescriptionMaxLength)
            throw new ArgumentOutOfRangeException(nameof(description));
        Description = description;
    }

    private void SetKey(string key)
    {
        if (string.IsNullOrWhiteSpace(key) || key.Length < 2 || key.Length > 10 || !key.All(char.IsLetter))
            throw ProjectDomainException.InvalidKey();
        Key = key.ToUpperInvariant();
    }

    private void ReorderStatuses()
    {
        int i = 0;
        foreach (var s in _statuses.OrderBy(s => s.Order))
            s.SetOrder(i++);
    }

    private void Touch() => UpdatedAt = DateTime.UtcNow;
}
