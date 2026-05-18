namespace Disciplaner.Domain.Exceptions;

public sealed class MembershipDomainException : DomainException
{
    public MembershipDomainException(string message) : base(message) { }

    public static MembershipDomainException AlreadyMember(string userId, string resourceId)
        => new($"User '{userId}' is already a member of resource '{resourceId}'.");

    public static MembershipDomainException MemberNotFound(string userId, string resourceId)
        => new($"User '{userId}' is not a member of resource '{resourceId}'.");

    public static MembershipDomainException CannotModifyOwner(string userId)
        => new($"User '{userId}' is the owner and cannot be demoted or removed.");

    public static MembershipDomainException InsufficientRole(string userId)
        => new($"User '{userId}' does not have sufficient permissions to perform this action.");

    public static MembershipDomainException CannotAssignRoleAboveSupervisor()
        => new("Members can only be assigned roles up to Supervisor. Admin role is reserved for the owner.");
}
