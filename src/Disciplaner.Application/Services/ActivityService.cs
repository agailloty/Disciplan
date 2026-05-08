using Disciplaner.Application.DTOs.Activity;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class ActivityService : IActivityService
{
    private readonly IUnitOfWork _uow;

    public ActivityService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<ActivityItemDto>> GetRecentActivityAsync(
        string userId, int limit = 20, CancellationToken cancellationToken = default)
    {
        var (tickets, comments) = await (
            _uow.Tickets.GetCreatedByUserAsync(userId, limit, cancellationToken),
            _uow.Comments.GetByAuthorAsync(userId, limit, cancellationToken)
        ).WhenAll();

        var items = new List<ActivityItemDto>(tickets.Count + comments.Count);

        foreach (var t in tickets)
        {
            var ticketRef = $"{t.Project.Key}-{t.TicketNumber}";
            items.Add(new ActivityItemDto("ticket_created", t.Title, ticketRef, t.Id, t.CreatedAt));
        }

        foreach (var c in comments)
        {
            var preview = c.Content.Length > 80 ? c.Content[..80] + "…" : c.Content;
            string? ticketRef = c.Ticket is not null
                ? $"{c.Ticket.Project.Key}-{c.Ticket.TicketNumber}"
                : null;
            items.Add(new ActivityItemDto("comment_added", preview, ticketRef, c.TicketId, c.CreatedAt));
        }

        return items.OrderByDescending(x => x.OccurredAt).Take(limit).ToList();
    }

    public async Task<IReadOnlyList<TicketActivityGroupDto>> GetRecentGroupedAsync(
        string userId, int limit = 20, CancellationToken cancellationToken = default)
    {
        // Pull recent history entries authored by the user
        var entries = await _uow.TicketHistory.GetRecentByUserAsync(userId, limit * 5, cancellationToken);

        var groups = entries
            .GroupBy(h => h.TicketId)
            .Select(g =>
            {
                var ticket = g.First().Ticket;
                var ticketRef = ticket?.Project is not null
                    ? $"{ticket.Project.Key}-{ticket.TicketNumber}"
                    : g.Key.ToString();
                var ticketTitle = ticket?.Title ?? string.Empty;

                var events = g
                    .OrderByDescending(h => h.OccurredAt)
                    .Select(h => new ActivityItemDto(h.Kind, BuildSummary(h), ticketRef, h.TicketId, h.OccurredAt))
                    .ToList()
                    .AsReadOnly();

                return new TicketActivityGroupDto(
                    g.Key,
                    ticketRef,
                    ticketTitle,
                    g.Max(h => h.OccurredAt),
                    events);
            })
            .OrderByDescending(g => g.LastOccurredAt)
            .Take(limit)
            .ToList()
            .AsReadOnly();

        return groups;
    }

    private static string BuildSummary(Domain.Entities.TicketHistory h) => h.Kind switch
    {
        "created"               => h.NewValue ?? string.Empty,
        "title_changed"         => $"{h.OldValue} → {h.NewValue}",
        "description_changed"   => "Description mise à jour",
        "status_changed"        => $"{h.OldValue} → {h.NewValue}",
        "type_changed"          => $"{h.OldValue} → {h.NewValue}",
        "priority_changed"      => $"{h.OldValue} → {h.NewValue}",
        "assignee_changed"      => h.NewValue is null ? "Non assigné" : $"→ {h.NewValue}",
        "sprint_changed"        => h.NewValue is null ? "Retiré du sprint" : $"→ {h.NewValue}",
        "story_points_changed"  => $"{h.OldValue ?? "—"} → {h.NewValue ?? "—"} pts",
        "due_date_changed"      => $"{h.OldValue ?? "—"} → {h.NewValue ?? "—"}",
        "comment_added"         => h.NewValue ?? string.Empty,
        "comment_deleted"       => h.OldValue ?? string.Empty,
        _                       => h.NewValue ?? h.OldValue ?? string.Empty
    };
}

file static class TaskTupleExtensions
{
    public static async Task<(T1, T2)> WhenAll<T1, T2>(this (Task<T1> t1, Task<T2> t2) tasks)
    {
        await Task.WhenAll(tasks.t1, tasks.t2);
        return (tasks.t1.Result, tasks.t2.Result);
    }
}
