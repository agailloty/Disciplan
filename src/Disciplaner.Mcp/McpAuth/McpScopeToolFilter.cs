using System.Security.Claims;
using Disciplaner.Domain.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using ModelContextProtocol.Protocol;
using ModelContextProtocol.Server;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// tools/list filter (review fix B): a personal access token with the 'read' scope only
/// sees the tools it can actually call. Tools annotated ReadOnly are kept, plus the
/// side-effect-free diagnostic tools (ping). 'read+write' tokens and requests without a
/// scope claim see the full list — the /mcp endpoint requires authentication anyway, so
/// the anonymous case is purely defensive. EnsureReadScope/EnsureWriteScope guards stay
/// in every tool: this filter is cosmetic surface reduction, not an authorization check.
/// </summary>
public static class McpScopeToolFilter
{
    /// <summary>Tools without the ReadOnly annotation that a read-only token may still see.</summary>
    private static readonly HashSet<string> SideEffectFreeTools = ["ping"];

    /// <summary>Delegate registered on McpServerOptions.Filters.Request.ListToolsFilters.</summary>
    public static McpRequestFilter<ListToolsRequestParams, ListToolsResult> HideWriteToolsFromReadOnlyTokens =>
        next => async (request, cancellationToken) =>
        {
            var result = await next(request, cancellationToken);

            var scopes = ResolvePrincipal(request)?.FindFirstValue(McpTokenDefaults.ScopesClaimType);
            if (scopes == McpTokenSecurity.ReadScope && result.Tools is not null)
            {
                result.Tools = result.Tools
                    .Where(t => t.Annotations?.ReadOnlyHint == true || SideEffectFreeTools.Contains(t.Name))
                    .ToList();
            }

            return result;
        };

    /// <summary>
    /// The MCP request context carries the authenticated principal; the HTTP context
    /// accessor is the fallback when the transport does not populate it.
    /// </summary>
    private static ClaimsPrincipal? ResolvePrincipal(RequestContext<ListToolsRequestParams> request)
    {
        if (request.User?.Identity?.IsAuthenticated == true)
            return request.User;
        return request.Services.GetService<IHttpContextAccessor>()?.HttpContext?.User;
    }
}
