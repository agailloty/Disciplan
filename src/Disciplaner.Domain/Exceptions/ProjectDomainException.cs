namespace Disciplaner.Domain.Exceptions;

public sealed class ProjectDomainException : DomainException
{
    public ProjectDomainException(string message) : base(message) { }

    public static ProjectDomainException EmptyName()
        => new("Project name cannot be empty.");

    public static ProjectDomainException NameTooLong(int max)
        => new($"Project name cannot exceed {max} characters.");

    public static ProjectDomainException InvalidKey()
        => new("Project key must be 2-10 uppercase letters (e.g. DISC).");

    public static ProjectDomainException SprintAlreadyActive(string sprintName)
        => new($"Cannot start sprint '{sprintName}': another sprint is already active.");

    public static ProjectDomainException SprintNotFound(Guid sprintId)
        => new($"Sprint '{sprintId}' does not belong to this project.");

    public static ProjectDomainException StatusNotFound(Guid statusId)
        => new($"Status '{statusId}' does not belong to this project.");

    public static ProjectDomainException StatusInUse()
        => new("Cannot delete a status that is currently assigned to tickets.");

    public static ProjectDomainException DefaultStatusRequired()
        => new("A project must have at least one status.");
}
