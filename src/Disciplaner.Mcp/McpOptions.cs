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

    /// <summary>
    /// Public base URL (e.g. https://mcp.example.com) used to build the RFC 9728/8414
    /// metadata documents and the WWW-Authenticate challenge. Set it when the server runs
    /// behind a TLS-terminating reverse proxy that does not forward X-Forwarded-Proto,
    /// so OAuth URLs are not advertised as http://. When empty, the request scheme and
    /// host are used.
    /// </summary>
    public string? PublicBaseUrl { get; set; }
}
