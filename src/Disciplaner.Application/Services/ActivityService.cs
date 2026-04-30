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
            items.Add(new ActivityItemDto(
                Kind: "ticket_created",
                Summary: t.Title,
                TicketRef: ticketRef,
                TicketId: t.Id,
                OccurredAt: t.CreatedAt));
        }

        foreach (var c in comments)
        {
            var preview = c.Content.Length > 80 ? c.Content[..80] + "…" : c.Content;
            string? ticketRef = c.Ticket is not null
                ? $"{c.Ticket.Project.Key}-{c.Ticket.TicketNumber}"
                : null;

            items.Add(new ActivityItemDto(
                Kind: "comment_added",
                Summary: preview,
                TicketRef: ticketRef,
                TicketId: c.TicketId,
                OccurredAt: c.CreatedAt));
        }

        return items
            .OrderByDescending(x => x.OccurredAt)
            .Take(limit)
            .ToList();
    }
}

file static class TaskTupleExtensions
{
    public static async Task<(T1, T2)> WhenAll<T1, T2>(this (Task<T1> t1, Task<T2> t2) tasks)
    {
        await Task.WhenAll(tasks.t1, tasks.t2);
        return (tasks.t1.Result, tasks.t2.Result);
    }
}
