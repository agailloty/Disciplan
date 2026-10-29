using Disciplaner.Domain.Common;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// RFC 9728 Protected Resource Metadata served on /.well-known/oauth-protected-resource
/// (review fix C). Disciplaner authenticates MCP clients with personal access tokens, not
/// OAuth 2.1: this document is a diagnostic signpost for spec-conforming clients that start
/// authorization-server discovery, not an authorization server announcement. The
/// "documentation" URI points at the personal access token guide.
/// </summary>
public static class ProtectedResource
{
    public const string Path = "/.well-known/oauth-protected-resource";

    /// <summary>Metadata document: the resource identifier plus a custom documentation field.</summary>
    public static object Metadata(string baseUrl, string documentationUrl) => new
    {
        resource = baseUrl,
        documentation = documentationUrl,
        scopes_supported = McpTokenSecurity.AllScopes
    };
}
