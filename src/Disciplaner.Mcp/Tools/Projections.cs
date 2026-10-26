using Disciplaner.Application.DTOs.Comment;
using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.DTOs.TicketStatus;

namespace Disciplaner.Mcp.Tools;

/// <summary>
/// Compact, LLM-friendly projections of the application DTOs: readable identifiers
/// (project key, ticket reference) always present, enums as strings, no bare GUIDs.
/// </summary>
public static class Projections
{
    // ── Projects ─────────────────────────────────────────────────────────────

    public sealed record McpProject(
        string ProjectKey, string Name, string? Description,
        int TicketCount, int SprintCount, string YourRole, bool IsOwner);

    public sealed record McpProjectDetail(
        string ProjectKey, string Name, string? Description,
        string DefaultTicketType, string YourRole,
        IReadOnlyList<McpStatus> Statuses, IReadOnlyList<McpMember> Members);

    public sealed record McpStatus(string Name, string Category, string Color, int Order);

    public sealed record McpMember(string DisplayName, string Email, string Role);

    // ── Tickets ──────────────────────────────────────────────────────────────

    public sealed record McpTicket(
        string TicketRef, string ProjectKey, string Title, string Type, string Priority,
        string Status, string StatusCategory, int? StoryPoints, string? DueDate,
        string? SprintName, string? Assignee, string? Reporter, string? ParentTicketRef);

    public sealed record McpTicketDetail(
        string TicketRef, string ProjectKey, string Title, string? Description,
        string Type, string Priority, string Status, string StatusCategory,
        int? StoryPoints, string? DueDate, string? SprintName, string? Assignee,
        string? Reporter, string? ParentTicketRef, DateTime CreatedAt, DateTime? UpdatedAt,
        IReadOnlyList<string> Labels);

    // ── Sprints ─────────────────────────────────────────────────────────────

    public sealed record McpSprint(
        string SprintId, string ProjectKey, string Name, string? Goal,
        string Status, string? StartDate, string? EndDate, int TicketCount);

    public sealed record McpSprintDetail(
        string SprintId, string ProjectKey, string Name, string? Goal,
        string Status, string? StartDate, string? EndDate,
        IReadOnlyList<McpTicket> Tickets);

    // ── Comments and labels ─────────────────────────────────────────────────

    public sealed record McpComment(string Author, string Content, DateTime CreatedAt, DateTime? UpdatedAt);

    public sealed record McpLabel(string Name, string Color);

    // ── Pages ───────────────────────────────────────────────────────────────

    public sealed record McpPage<T>(IReadOnlyList<T> Items, int TotalCount, int Offset, int Limit);

    public static McpPage<T> Page<T>(IReadOnlyList<T> source, int limit, int offset)
        => new(source.Skip(offset).Take(limit).ToList(), source.Count, offset, limit);

    // ── Mappers ─────────────────────────────────────────────────────────────

    public static McpProject ToProject(ProjectSummaryDto p)
        => new(p.Key, p.Name, p.Description, p.TicketCount, p.SprintCount, p.RequestingUserRole.ToString(), p.IsOwner);

    public static McpProjectDetail ToProjectDetail(ProjectDetailDto p) => new(
        p.Key, p.Name, p.Description, p.DefaultTicketType.ToString(), p.RequestingUserRole.ToString(),
        p.Statuses.Select(ToStatus).ToList(),
        p.Members.Select(m => new McpMember(m.DisplayName, m.Email, m.Role.ToString())).ToList());

    public static McpStatus ToStatus(TicketStatusDto s)
        => new(s.Name, s.Category.ToString(), s.Color, s.Order);

    public static McpTicket ToTicket(TicketDto t) => new(
        t.TicketRef, t.ProjectKey, t.Title, t.Type.ToString(), t.Priority.ToString(),
        t.Status.Name, t.Status.Category.ToString(), t.StoryPoints,
        t.DueDate?.ToString("yyyy-MM-dd"), t.SprintName, t.AssigneeName, t.ReporterName, t.ParentTicketRef);

    public static McpTicketDetail ToTicketDetail(TicketDto t) => new(
        t.TicketRef, t.ProjectKey, t.Title, t.Description,
        t.Type.ToString(), t.Priority.ToString(), t.Status.Name, t.Status.Category.ToString(),
        t.StoryPoints, t.DueDate?.ToString("yyyy-MM-dd"), t.SprintName, t.AssigneeName,
        t.ReporterName, t.ParentTicketRef, t.CreatedAt, t.UpdatedAt,
        t.Labels.Select(l => l.Name).ToList());

    public static McpSprint ToSprint(SprintDto s, string? projectKey = null) => new(
        s.Id.ToString(), projectKey ?? s.ProjectKey ?? s.ProjectId.ToString(), s.Name, s.Goal,
        s.Status.ToString(), s.StartDate?.ToString("yyyy-MM-dd"), s.EndDate?.ToString("yyyy-MM-dd"), s.TicketCount);

    public static McpSprintDetail ToSprintDetail(SprintDetailDto s, IReadOnlyList<TicketDto> tickets) => new(
        s.Id.ToString(), s.ProjectKey, s.Name, s.Goal, s.Status.ToString(),
        s.StartDate?.ToString("yyyy-MM-dd"), s.EndDate?.ToString("yyyy-MM-dd"),
        tickets.Select(ToTicket).ToList());

    public static McpComment ToComment(CommentDto c)
        => new(c.AuthorName, c.Content, c.CreatedAt, c.UpdatedAt);

    public static McpLabel ToLabel(LabelDto l)
        => new(l.Name, l.Color);
}
