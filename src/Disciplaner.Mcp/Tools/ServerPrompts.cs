using ModelContextProtocol.Protocol;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

/// <summary>
/// Server prompts guiding common LLM workflows. They contain instructions and tool
/// calls only — no server-side logic (§5.5 of the design).
/// </summary>
[McpServerPromptType]
public static class ServerPrompts
{
    [McpServerPrompt(Name = "enrich-backlog"), Description("Turn a raw product objective into a structured, validated ticket list, then create it in the backlog.")]
    public static GetPromptResult EnrichBacklog(
        [Description("Short project key, e.g. 'DISC'.")] string project_key,
        [Description("The raw product objective or feature idea to break down.")] string objective)
        => new()
        {
            Messages =
            [
                new PromptMessage
                {
                    Role = Role.User,
                    Content = new TextContentBlock
                    {
                        Text =
                            $"Project: {project_key}. Objective: {objective}\n\n" +
                            "1. Use list_tickets and list_sprints on this project to see what already exists and avoid duplicates.\n" +
                            "2. Break the objective down into 3-8 small, actionable tickets (title, type, priority, story points, short description).\n" +
                            "3. Present the proposed list to the user and ask for validation. Do NOT create anything yet.\n" +
                            "4. Once the user approves (possibly with edits), create the tickets with create_tickets in the backlog (no sprint), " +
                            "and report the created references (e.g. 'DISC-5') back to the user."
                    }
                }
            ]
        };

    [McpServerPrompt(Name = "sprint-review"), Description("Summarize the current state of a project's active sprint: done, in progress, blocked.")]
    public static GetPromptResult SprintReview(
        [Description("Short project key, e.g. 'DISC'.")] string project_key)
        => new()
        {
            Messages =
            [
                new PromptMessage
                {
                    Role = Role.User,
                    Content = new TextContentBlock
                    {
                        Text =
                            $"Project: {project_key}\n\n" +
                            "1. Use list_sprints to find the Active sprint of this project (or report that none is active).\n" +
                            "2. Use get_sprint on it to list its tickets.\n" +
                            "3. Summarize: tickets done, in progress, not started, total story points, anything overdue (due_date in the past). " +
                            "Keep it short and end with the two or three tickets that deserve attention."
                    }
                }
            ]
        };
}
