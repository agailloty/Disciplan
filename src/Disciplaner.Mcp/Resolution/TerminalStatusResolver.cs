using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Enums;
using ModelContextProtocol;

namespace Disciplaner.Mcp.Resolution;

/// <summary>
/// Maps "closing a ticket" to the project's terminal status (§7.3 of the design).
/// Statuses are project-custom, so the rule is: (a) the Done-category status named
/// "Done" or "Terminé" (case-insensitive), (b) the single Done-category status,
/// otherwise (c) an error listing the available statuses and asking the LLM to
/// check with the user.
/// </summary>
public sealed class TerminalStatusResolver(IProjectService projects)
{
    public async Task<TicketStatusDto> ResolveTerminalStatusAsync(
        Guid projectId, string projectKey, string userId, CancellationToken ct)
    {
        var project = await projects.GetByIdAsync(projectId, userId, ct)
            ?? throw new McpException($"Project '{projectKey}' is not accessible with this account.");

        var doneStatuses = project.Statuses.Where(s => s.Category == StatusCategory.Done).ToList();

        var canonical = doneStatuses.FirstOrDefault(s =>
            string.Equals(s.Name, "Done", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(s.Name, "Terminé", StringComparison.OrdinalIgnoreCase));
        if (canonical is not null) return canonical;

        if (doneStatuses.Count == 1) return doneStatuses[0];

        var available = string.Join(", ", project.Statuses.Select(s => $"'{s.Name}' ({s.Category})"));
        if (doneStatuses.Count > 1)
            throw new McpException(
                $"Project {projectKey} has several Done statuses: " +
                string.Join(", ", doneStatuses.Select(s => $"'{s.Name}'")) +
                $". Ask the user which terminal status to use, then change it with the status id. Project statuses: {available}.");
        throw new McpException(
            $"Project {projectKey} has no Done status, so the ticket cannot be closed automatically. " +
            $"Ask the user which status to use. Project statuses: {available}.");
    }
}
