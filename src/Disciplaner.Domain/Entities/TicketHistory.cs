namespace Disciplaner.Domain.Entities;

/// <summary>
/// Immutable audit record for a change on a ticket.
/// <para>
/// <b>Kind</b> values:
/// <list type="bullet">
///   <item><c>created</c>      — ticket was created</item>
///   <item><c>title_changed</c></item>
///   <item><c>description_changed</c></item>
///   <item><c>status_changed</c></item>
///   <item><c>type_changed</c></item>
///   <item><c>priority_changed</c></item>
///   <item><c>assignee_changed</c></item>
///   <item><c>sprint_changed</c></item>
///   <item><c>story_points_changed</c></item>
///   <item><c>due_date_changed</c></item>
///   <item><c>comment_added</c></item>
///   <item><c>comment_deleted</c></item>
///   <item><c>attachment_added</c>  — OldValue = attachmentId, NewValue = fileName</item>
/// </list>
/// </para>
/// </summary>
public class TicketHistory
{
    public Guid Id { get; private init; } = Guid.NewGuid();
    public Guid TicketId { get; private init; }
    public Ticket Ticket { get; private set; } = null!;

    public string Kind { get; private init; } = string.Empty;
    /// <summary>Human-readable description (e.g. "Medium → High").</summary>
    public string? OldValue { get; private init; }
    public string? NewValue { get; private init; }

    /// <summary>Identity userId of the actor.</summary>
    public string ActorId { get; private init; } = string.Empty;
    /// <summary>Display name stored at the time of the event (denormalized for speed).</summary>
    public string ActorName { get; private init; } = string.Empty;

    public DateTime OccurredAt { get; private init; } = DateTime.UtcNow;

    protected TicketHistory() { }

    public static TicketHistory Record(
        Guid ticketId,
        string kind,
        string actorId,
        string actorName,
        string? oldValue = null,
        string? newValue = null)
        => new()
        {
            TicketId   = ticketId,
            Kind       = kind,
            ActorId    = actorId,
            ActorName  = actorName,
            OldValue   = oldValue,
            NewValue   = newValue,
            OccurredAt = DateTime.UtcNow
        };
}
