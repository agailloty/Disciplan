namespace Disciplaner.Mcp;

/// <summary>Bound to the "Mcp" configuration section.</summary>
public sealed class McpOptions
{
    public const string SectionName = "Mcp";

    /// <summary>When false, the /mcp endpoint is not mapped at all (404).</summary>
    public bool Enabled { get; set; } = true;

    /// <summary>Maximum number of tickets accepted in a single create_tickets call (lot 05).</summary>
    public int MaxBatchTickets { get; set; } = 50;

    /// <summary>Maximum MCP requests per token per minute.</summary>
    public int RateLimitPerMinute { get; set; } = 60;

    /// <summary>
    /// URI of the personal access token documentation, served in the RFC 9728 metadata
    /// document (review fix C). Override to point at your own hosted docs.
    /// </summary>
    public string PatDocumentationUrl { get; set; } =
        "https://github.com/agailloty/Disciplan/blob/master/docs/mcp-connector/02-guide-utilisateur.md";
}
