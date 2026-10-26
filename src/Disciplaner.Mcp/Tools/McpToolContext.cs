using Disciplaner.Domain.Common;
using Disciplaner.Mcp.McpAuth;
using Microsoft.AspNetCore.Http;
using ModelContextProtocol;
using System.Security.Claims;

namespace Disciplaner.Mcp.Tools;

/// <summary>
/// Exposes the authenticated MCP caller (PAT principal) to tool implementations:
/// user id and token scopes. Same claim shape as the JWT flow.
/// </summary>
public sealed class McpToolContext
{
    public const int DefaultPageSize = 50;
    public const int MaxPageSize = 100;

    private readonly IHttpContextAccessor _accessor;

    public McpToolContext(IHttpContextAccessor accessor) => _accessor = accessor;

    private ClaimsPrincipal Principal
        => _accessor.HttpContext?.User
            ?? throw new InvalidOperationException("No HTTP context available for the MCP tool call.");

    /// <summary>User id resolved by the services — identical to the controllers' UserId.</summary>
    public string UserId
        => Principal.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new McpException("The MCP request is not authenticated with a Disciplaner personal access token.");

    public void EnsureReadScope()
    {
        var scopes = Principal.FindFirstValue(McpTokenDefaults.ScopesClaimType);
        if (scopes != McpTokenSecurity.ReadScope && scopes != McpTokenSecurity.ReadWriteScope)
            throw new McpException("This token does not allow read operations. Create a personal access token with the 'read' scope.");
    }

    public void EnsureWriteScope()
    {
        var scopes = Principal.FindFirstValue(McpTokenDefaults.ScopesClaimType);
        if (scopes != McpTokenSecurity.ReadWriteScope)
            throw new McpException("This token is read-only. Create a personal access token with the 'read+write' scope to perform write operations.");
    }

    /// <summary>Deep link a user can click to open the ticket in the Disciplaner web client.</summary>
    public string TicketUrl(string ticketRef)
    {
        var request = _accessor.HttpContext?.Request;
        var baseUrl = request is null
            ? string.Empty
            : $"{request.Scheme}://{request.Host}";
        return $"{baseUrl}/tickets/{ticketRef}";
    }

    /// <summary>Normalizes limit/offset tool arguments; rejects limits above the maximum.</summary>
    public (int Limit, int Offset) NormalizePaging(int? limit, int? offset)
    {
        var value = limit ?? DefaultPageSize;
        if (value is < 1)
            throw new McpException("'limit' must be at least 1.");
        if (value > MaxPageSize)
            throw new McpException($"'limit' must be at most {MaxPageSize}; the request for {value} was refused. Page through the results with 'offset' instead.");
        var skip = offset ?? 0;
        if (skip < 0)
            throw new McpException("'offset' must be 0 or more.");
        return (value, skip);
    }
}
