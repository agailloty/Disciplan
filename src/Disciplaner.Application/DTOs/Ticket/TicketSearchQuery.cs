using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Ticket;

/// <summary>
/// Search/filter criteria for tickets, always scoped to the requesting user's accessible
/// projects (rights filtering happens before projection, per D01).
/// </summary>
public sealed record TicketSearchQuery
{
    public Guid? ProjectId { get; init; }
    public Guid? SprintId { get; init; }
    public StatusCategory? StatusCategory { get; init; }
    public TicketType? Type { get; init; }
    public string? AssigneeId { get; init; }
    public string? ReporterId { get; init; }
    public bool AssignedToMe { get; init; }
    public bool ReportedByMe { get; init; }
    public int Limit { get; init; } = 100;
    public int Offset { get; init; }

    public const int MaxLimit = 100;

    public int EffectiveLimit => Math.Clamp(Limit, 1, MaxLimit);
    public int EffectiveOffset => Math.Max(Offset, 0);

    /// <summary>Effective assignee/reporter ids after resolving the assigned-to-me / reported-by-me shorthands.</summary>
    public (string? AssigneeId, string? ReporterId) EffectiveUsers(string userId)
        => (AssignedToMe ? userId : AssigneeId, ReportedByMe ? userId : ReporterId);
}
