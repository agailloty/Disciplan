using Disciplaner.Domain.Enums;

namespace Disciplaner.Domain.Entities;

public class BoardMember
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public Guid BoardId { get; private init; }
    public string UserId { get; private init; } = string.Empty;
    public MemberRole Role { get; private set; }
    public DateTime JoinedAt { get; private init; } = DateTime.UtcNow;

    protected BoardMember() { }

    internal BoardMember(Guid boardId, string userId, MemberRole role)
    {
        BoardId = boardId;
        UserId = userId;
        Role = role;
    }

    internal void ChangeRole(MemberRole newRole) => Role = newRole;
}
