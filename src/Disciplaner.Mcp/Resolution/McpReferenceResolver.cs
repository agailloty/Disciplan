using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.Interfaces;
using ModelContextProtocol;
using System.Text.RegularExpressions;

namespace Disciplaner.Mcp.Resolution;

/// <summary>
/// Resolves human-friendly identifiers (project key, ticket reference, sprint name,
/// member display name) into application DTOs, within the user's accessible projects
/// only. Ambiguities and unknown values produce actionable MCP errors (M04, §7.1).
/// </summary>
public sealed partial class McpReferenceResolver(
    IProjectService projects,
    ISprintService sprints,
    IProjectMemberService members,
    ITicketService tickets)
{
    [GeneratedRegex(@"^\s*([A-Za-z0-9]+)-(\d+)\s*$")]
    private static partial Regex TicketRefRegex();

    /// <summary>Parses a ticket reference like "DISC-42". Returns null when not well-formed.</summary>
    public static (string ProjectKey, int TicketNumber)? ParseTicketRef(string? ticketRef)
    {
        if (ticketRef is null) return null;
        var match = TicketRefRegex().Match(ticketRef);
        return match.Success && int.TryParse(match.Groups[2].Value, out var number)
            ? (match.Groups[1].Value.ToUpperInvariant(), number)
            : null;
    }

    public static bool IsGuid(string? value)
        => Guid.TryParse(value, out _);

    /// <summary>Resolves a project key (case-insensitive) among the user's accessible projects.</summary>
    public async Task<ProjectSummaryDto> ResolveProjectAsync(string projectKey, string userId, CancellationToken ct)
    {
        var all = await projects.GetAllByUserAsync(userId, ct);
        var match = all.FirstOrDefault(p => string.Equals(p.Key, projectKey, StringComparison.OrdinalIgnoreCase))
            ?? throw new McpException(
                $"Project key '{projectKey}' was not found among your accessible projects. " +
                $"Available keys: {string.Join(", ", all.Select(p => p.Key))}. Use list_projects for details.");
        return match;
    }

    /// <summary>Resolves a project by key (preferred) or by GUID id.</summary>
    public async Task<ProjectSummaryDto> ResolveProjectAsync(string? projectKey, string? projectId, string userId, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(projectKey))
            return await ResolveProjectAsync(projectKey, userId, ct);
        if (projectId is not null && Guid.TryParse(projectId, out var id))
        {
            var detail = await projects.GetByIdAsync(id, userId, ct)
                ?? throw new McpException(
                    $"Project '{projectId}' was not found or you are not a member. " +
                    "Use list_projects to see your accessible projects.");
            return new ProjectSummaryDto(detail.Id, detail.Name, detail.Description, detail.Key,
                0, detail.Sprints.Count, detail.CreatedAt, detail.RequestingUserRole, false);
        }
        throw new McpException("Provide either 'project_key' (e.g. 'DISC') or 'project_id' (GUID).");
    }

    /// <summary>Resolves a ticket by reference ("KEY-42"), or by GUID id.</summary>
    public async Task<TicketDto> ResolveTicketAsync(string? ticketRef, string? ticketId, string userId, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(ticketRef))
        {
            var parsed = ParseTicketRef(ticketRef);
            if (parsed is null)
                throw new McpException(
                    $"'{ticketRef}' is not a valid ticket reference. Use the format KEY-number, e.g. 'DISC-42'.");
            var (key, number) = parsed.Value;
            var ticket = await tickets.GetByRefAsync(key, number, userId, ct)
                ?? throw new McpException(
                    $"Ticket {key}-{number} was not found in project {key}. " +
                    "Use list_tickets (or get_project then get_sprint) to browse available tickets.");
            return ticket;
        }

        if (ticketId is not null && Guid.TryParse(ticketId, out var id))
        {
            var ticket = await tickets.GetByIdAsync(id, userId, ct)
                ?? throw new McpException(
                    $"Ticket '{ticketId}' was not found or you don't have access to its project. " +
                    "Use list_tickets to browse available tickets.");
            return ticket;
        }

        throw new McpException("Provide either 'ticket_ref' (e.g. 'DISC-42') or 'ticket_id' (GUID).");
    }

    /// <summary>Resolves a sprint by name (case-insensitive) within a project.</summary>
    public async Task<SprintDto> ResolveSprintAsync(Guid projectId, string projectKey, string sprintName, string userId, CancellationToken ct)
    {
        var all = await sprints.GetByProjectAsync(projectId, userId, ct);
        var candidates = all.Where(s => string.Equals(s.Name, sprintName, StringComparison.OrdinalIgnoreCase)).ToList();
        if (candidates.Count == 1) return candidates[0];

        if (candidates.Count > 1)
            throw new McpException(
                $"Multiple sprints named '{sprintName}' exist in project {projectKey}: " +
                string.Join("; ", candidates.Select(c => $"{c.Name} ({c.Status}, sprint_id {c.Id})")) +
                ". Provide 'sprint_id' to disambiguate.");

        throw new McpException(
            $"Sprint '{sprintName}' was not found in project {projectKey}. " +
            $"Known sprints: {string.Join(", ", all.Select(s => $"'{s.Name}' ({s.Status})"))}. " +
            "Use list_sprints to browse them.");
    }

    /// <summary>Resolves a project member by display name (case-insensitive).</summary>
    public async Task<MemberDto> ResolveMemberAsync(Guid projectId, string projectKey, string displayName, string userId, CancellationToken ct)
    {
        var all = await members.GetMembersAsync(projectId, userId, ct);
        var candidates = all.Where(m => string.Equals(m.DisplayName, displayName, StringComparison.OrdinalIgnoreCase)).ToList();
        if (candidates.Count == 1) return candidates[0];

        if (candidates.Count > 1)
            throw new McpException(
                $"Multiple members named '{displayName}' exist in project {projectKey}: " +
                string.Join("; ", candidates.Select(c => $"{c.DisplayName} ({c.Email})")) +
                ". Ask the user which one to use, or provide 'assignee_id'.");

        throw new McpException(
            $"Member '{displayName}' was not found in project {projectKey}. " +
            $"Known members: {string.Join(", ", all.Select(m => m.DisplayName))}. Use list_members to browse them.");
    }
}
