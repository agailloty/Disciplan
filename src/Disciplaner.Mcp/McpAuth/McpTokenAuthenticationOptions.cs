using Microsoft.AspNetCore.Authentication;

namespace Disciplaner.Mcp.McpAuth;

public static class McpTokenDefaults
{
    public const string AuthenticationScheme = "DisciplanerMcpToken";

    /// <summary>Claim carrying the token scopes ("read" or "read+write") for tool-level checks.</summary>
    public const string ScopesClaimType = "mcp_scopes";

    /// <summary>Claim carrying the token display name, for logging and audit.</summary>
    public const string TokenNameClaimType = "mcp_token_name";
}

public sealed class McpTokenAuthenticationOptions : AuthenticationSchemeOptions
{
}
