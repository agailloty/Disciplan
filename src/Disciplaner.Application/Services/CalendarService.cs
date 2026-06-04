using System.Text;
using Disciplaner.Application.DTOs.Calendar;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class CalendarService : ICalendarService
{
    private readonly IUnitOfWork _uow;

    public CalendarService(IUnitOfWork uow) => _uow = uow;

    // ── Token management ─────────────────────────────────────────────────────

    public async Task<CalendarTokenDto?> GetTokenAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var token = await _uow.CalendarTokens.GetByUserIdAsync(userId, cancellationToken);
        return token is null ? null : ToDto(token);
    }

    public async Task<CalendarTokenDto> GenerateTokenAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var existing = await _uow.CalendarTokens.GetByUserIdAsync(userId, cancellationToken);
        if (existing is not null)
        {
            // Delete the old token and create a fresh one.
            await _uow.CalendarTokens.DeleteAsync(existing, cancellationToken);
        }

        var token = new CalendarToken(userId);
        await _uow.CalendarTokens.AddAsync(token, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return ToDto(token);
    }

    public async Task RevokeTokenAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var token = await _uow.CalendarTokens.GetByUserIdAsync(userId, cancellationToken);
        if (token is null) return;
        await _uow.CalendarTokens.DeleteAsync(token, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    // ── iCal feed ────────────────────────────────────────────────────────────

    public async Task<string?> BuildICalFeedAsync(
        string token, string baseUrl, CancellationToken cancellationToken = default)
    {
        var calToken = await _uow.CalendarTokens.GetByTokenAsync(token, cancellationToken);
        if (calToken is null) return null;

        calToken.RecordAccess();
        await _uow.CalendarTokens.UpdateAsync(calToken, cancellationToken);

        var userId = calToken.UserId;

        // Load data in parallel
        var ticketsTask = _uow.Tickets.GetAssignedToUserAsync(userId, cancellationToken);
        var cardsTask = _uow.Cards.GetAssignedToUserWithDueDateAsync(userId, cancellationToken);
        var sprintsTask = _uow.Sprints.GetWithDatesForUserAsync(userId, cancellationToken);

        await Task.WhenAll(ticketsTask, cardsTask, sprintsTask);

        var tickets = ticketsTask.Result;
        var cards = cardsTask.Result;
        var sprints = sprintsTask.Result;

        await _uow.SaveChangesAsync(cancellationToken);

        var sb = new StringBuilder();
        sb.AppendLine("BEGIN:VCALENDAR");
        sb.AppendLine("VERSION:2.0");
        sb.AppendLine("PRODID:-//Disciplaner//Calendar Feed//EN");
        sb.AppendLine("CALSCALE:GREGORIAN");
        sb.AppendLine("METHOD:PUBLISH");
        sb.AppendLine("X-WR-CALNAME:Disciplaner");
        sb.AppendLine("X-WR-CALDESC:Your tickets and sprints from Disciplaner");
        sb.AppendLine("X-WR-TIMEZONE:UTC");

        foreach (var ticket in tickets.Where(t => t.DueDate.HasValue))
        {
            AppendTicketEvent(sb, ticket, baseUrl);
        }

        foreach (var card in cards)
        {
            AppendCardEvent(sb, card, baseUrl);
        }

        foreach (var sprint in sprints)
        {
            AppendSprintEvent(sb, sprint, baseUrl);
        }

        sb.AppendLine("END:VCALENDAR");
        return sb.ToString();
    }

    // ── Event builders ───────────────────────────────────────────────────────

    private static void AppendTicketEvent(StringBuilder sb, Ticket ticket, string baseUrl)
    {
        var dueDate = ticket.DueDate!.Value;
        var projectKey = ticket.Project?.Key ?? "TICKET";
        var ticketRef = $"{projectKey}-{ticket.TicketNumber}";
        var priority = MapPriority(ticket.Priority);
        var url = $"{baseUrl.TrimEnd('/')}/tickets/{ticket.Id}";
        var description = BuildDescription(
            new[] { ("Type", ticket.Type.ToString()), ("Priority", ticket.Priority.ToString()), ("Status", ticket.Status?.Name ?? "") },
            url);

        sb.AppendLine("BEGIN:VEVENT");
        sb.AppendLine($"UID:ticket-{ticket.Id}@disciplaner");
        sb.AppendLine($"DTSTAMP:{FormatUtcNow()}");
        sb.AppendLine($"DTSTART;VALUE=DATE:{dueDate:yyyyMMdd}");
        sb.AppendLine($"DTEND;VALUE=DATE:{dueDate.AddDays(1):yyyyMMdd}");
        sb.AppendLine($"SUMMARY:[{ticketRef}] {EscapeText(ticket.Title)}");
        sb.AppendLine($"DESCRIPTION:{description}");
        sb.AppendLine($"URL:{url}");
        sb.AppendLine($"PRIORITY:{priority}");
        sb.AppendLine($"CATEGORIES:Ticket,{ticket.Type}");
        sb.AppendLine("END:VEVENT");
    }

    private static void AppendCardEvent(StringBuilder sb, Card card, string baseUrl)
    {
        var dueDate = card.DueDate!.Value;
        var url = $"{baseUrl.TrimEnd('/')}/boards/{card.Column?.BoardId.ToString() ?? ""}";
        var description = BuildDescription(
            new[] { ("Priority", card.Priority.ToString()), ("Board", card.Column?.Board?.Name ?? "") },
            url);

        sb.AppendLine("BEGIN:VEVENT");
        sb.AppendLine($"UID:card-{card.Id}@disciplaner");
        sb.AppendLine($"DTSTAMP:{FormatUtcNow()}");
        sb.AppendLine($"DTSTART;VALUE=DATE:{dueDate:yyyyMMdd}");
        sb.AppendLine($"DTEND;VALUE=DATE:{dueDate.AddDays(1):yyyyMMdd}");
        sb.AppendLine($"SUMMARY:[Card] {EscapeText(card.Title)}");
        sb.AppendLine($"DESCRIPTION:{description}");
        sb.AppendLine($"URL:{url}");
        sb.AppendLine($"PRIORITY:{MapPriority(card.Priority)}");
        sb.AppendLine("CATEGORIES:Card");
        sb.AppendLine("END:VEVENT");
    }

    private static void AppendSprintEvent(StringBuilder sb, Sprint sprint, string baseUrl)
    {
        var start = sprint.StartDate!.Value;
        var end = sprint.EndDate!.Value;
        var projectName = sprint.Project?.Name ?? "";
        var url = $"{baseUrl.TrimEnd('/')}/sprints/{sprint.Id}";
        var description = BuildDescription(
            new[] { ("Project", projectName), ("Status", sprint.Status.ToString()), ("Goal", sprint.Goal ?? "") },
            url);

        sb.AppendLine("BEGIN:VEVENT");
        sb.AppendLine($"UID:sprint-{sprint.Id}@disciplaner");
        sb.AppendLine($"DTSTAMP:{FormatUtcNow()}");
        sb.AppendLine($"DTSTART;VALUE=DATE:{start:yyyyMMdd}");
        sb.AppendLine($"DTEND;VALUE=DATE:{end.AddDays(1):yyyyMMdd}");
        sb.AppendLine($"SUMMARY:[Sprint] {EscapeText(sprint.Name)}");
        sb.AppendLine($"DESCRIPTION:{description}");
        sb.AppendLine($"URL:{url}");
        sb.AppendLine("CATEGORIES:Sprint");
        sb.AppendLine("END:VEVENT");
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string FormatUtcNow() => DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmss'Z'");

    /// <summary>
    /// Maps CardPriority to RFC 5545 PRIORITY values (1=highest, 9=lowest).
    /// Calendar clients use: 1-4 high, 5 normal, 6-9 low.
    /// </summary>
    private static int MapPriority(Domain.Enums.CardPriority priority) => priority switch
    {
        Domain.Enums.CardPriority.Critical => 1,
        Domain.Enums.CardPriority.High     => 3,
        Domain.Enums.CardPriority.Medium   => 5,
        Domain.Enums.CardPriority.Low      => 9,
        _                                  => 5
    };

    /// <summary>Escapes commas, semicolons and backslashes as required by RFC 5545.</summary>
    private static string EscapeText(string text)
        => text.Replace("\\", "\\\\").Replace(";", "\\;").Replace(",", "\\,").Replace("\n", "\\n").Replace("\r", "");

    private static string BuildDescription(IEnumerable<(string Key, string Value)> fields, string url)
    {
        var parts = fields
            .Where(f => !string.IsNullOrWhiteSpace(f.Value))
            .Select(f => $"{f.Key}: {f.Value}");
        return EscapeText(string.Join(" | ", parts) + $" | {url}");
    }

    private static CalendarTokenDto ToDto(CalendarToken token)
        => new(token.Token, token.CreatedAt, token.LastAccessedAt);
}
