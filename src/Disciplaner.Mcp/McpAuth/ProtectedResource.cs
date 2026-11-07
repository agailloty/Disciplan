using Disciplaner.Domain.Common;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// RFC 9728 Protected Resource Metadata served on /.well-known/oauth-protected-resource.
/// Conforms to modern MCP Authorization Specification by advertising the OAuth 2.1 authorization servers.
/// </summary>
public static class ProtectedResource
{
    public const string Path = "/.well-known/oauth-protected-resource";

    /// <summary>
    /// Metadata document according to RFC 9728: announces the protected resource and authorization servers.
    /// </summary>
    public static object Metadata(string baseUrl, string documentationUrl) => new
    {
        resource = baseUrl,
        authorization_servers = new[] { baseUrl },
        scopes_supported = McpTokenSecurity.AllScopes,
        bearer_methods_supported = new[] { "header" },
        documentation = documentationUrl,
        resource_documentation = documentationUrl
    };
}
