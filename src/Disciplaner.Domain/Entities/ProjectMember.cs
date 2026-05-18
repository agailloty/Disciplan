using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Entities;

public class ProjectMember
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public Guid ProjectId { get; private init; }
    public string UserId { get; private init; } = string.Empty;
    public MemberRole Role { get; private set; }
    public DateTime JoinedAt { get; private init; } = DateTime.UtcNow;

    protected ProjectMember() { }

    internal ProjectMember(Guid projectId, string userId, MemberRole role)
    {
        ProjectId = projectId;
        UserId = userId;
        Role = role;
    }

    internal void ChangeRole(MemberRole newRole) => Role = newRole;
}
