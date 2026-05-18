namespace Disciplaner.Domain.Enums;

/// <summary>
/// Role of a user within a specific Board or Project.
/// Higher numeric value = more permissions.
/// </summary>
public enum MemberRole
{
    /// <summary>Read-only access. Can view content but cannot create or modify anything.</summary>
    Guest = 0,

    /// <summary>
    /// Can create cards/tickets and edit/delete their own content.
    /// Can move cards between columns and add comments.
    /// </summary>
    Member = 1,

    /// <summary>
    /// All Member permissions plus: edit/delete any content,
    /// manage columns/statuses, manage sprints.
    /// </summary>
    Supervisor = 2,

    /// <summary>
    /// Full control: all Supervisor permissions plus board/project settings,
    /// invite/remove members, assign roles up to Supervisor, delete the resource.
    /// </summary>
    Admin = 3
}
