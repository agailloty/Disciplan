using Disciplaner.Mcp.McpAuth;
using Disciplaner.Mcp.OAuth;
using Disciplaner.Mcp.Resolution;
using Disciplaner.Mcp.Tools;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using ModelContextProtocol.Server;
using System.Security.Claims;
using System.Threading.RateLimiting;

namespace Disciplaner.Mcp;

public static class DependencyInjection
{
    /// <summary>Rate-limiting policy applied to the /mcp endpoint.</summary>
    public const string RateLimitPolicy = "mcp";

    public static IServiceCollection AddDisciplanerMcp(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<McpOptions>()
            .Bind(configuration.GetSection(McpOptions.SectionName))
            .ValidateDataAnnotations()
            .Validate(o => o.MaxBatchTickets > 0, "Mcp:MaxBatchTickets must be positive.")
            .Validate(o => o.RateLimitPerMinute > 0, "Mcp:RateLimitPerMinute must be positive.");

        // MCP authentication (supports OAuth 2.1 Access Tokens and Personal Access Tokens)
        services.AddAuthentication()
            .AddScheme<McpTokenAuthenticationOptions, McpTokenAuthenticationHandler>(
                McpTokenDefaults.AuthenticationScheme, _ => { });

        services.AddScoped<McpTokenService>();
        services.AddScoped<McpOAuthService>();

        // IMemoryCache gates the LastUsedAt flushes (one write per token per 5-minute window).
        // AddMemoryCache uses TryAdd: an existing registration is left untouched.
        services.AddMemoryCache();

        // Tool plumbing
        services.AddHttpContextAccessor();
        services.AddScoped<McpToolContext>();
        services.AddScoped<McpReferenceResolver>();
        services.AddScoped<TerminalStatusResolver>();

        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.AddPolicy(RateLimitPolicy, context =>
            {
                // One bucket per authenticated token owner; all anonymous traffic shares one bucket.
                var key = context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anonymous";
                return RateLimitPartition.GetFixedWindowLimiter(key, _ =>
                    new FixedWindowRateLimiterOptions
                    {
                        PermitLimit = context.RequestServices
                            .GetRequiredService<IOptions<McpOptions>>().Value.RateLimitPerMinute,
                        Window = TimeSpan.FromMinutes(1),
                        QueueLimit = 0
                    });
            });
        });

        services.AddMcpServer(options =>
        {
            options.ServerInstructions =
                "Disciplaner is a self-hosted project management tool (projects, tickets, sprints). " +
                "Tickets are referenced as KEY-number, e.g. DISC-42, where KEY is the short project key. " +
                "All dates are ISO 8601 UTC.";
            // A 'read' token only lists the tools it can call.
            options.Filters.Request.ListToolsFilters.Add(McpScopeToolFilter.HideWriteToolsFromReadOnlyTokens);
        })
        .WithHttpTransport(options => options.Stateless = true)
        .WithToolsFromAssembly(typeof(DependencyInjection).Assembly)
        .WithPromptsFromAssembly(typeof(DependencyInjection).Assembly);

        return services;
    }

    /// <summary>
    /// Maps the MCP Streamable HTTP endpoint, authenticated with an OAuth 2.1 access token or Disciplaner PAT,
    /// alongside the OAuth 2.1 authorization server endpoints (RFC 6749, RFC 7591, RFC 7636, RFC 8414, RFC 9728).
    /// Returns null (and maps nothing → 404) when Mcp:Enabled is false.
    /// </summary>
    public static IEndpointConventionBuilder? MapDisciplanerMcp(this IEndpointRouteBuilder app, string pattern = "/mcp")
    {
        var options = app.ServiceProvider.GetRequiredService<IOptions<McpOptions>>().Value;
        if (!options.Enabled)
        {
            // Map an explicit 404 instead of letting requests fall through to the SPA fallback,
            // so MCP clients get an unambiguous "not available" answer on any verb.
            app.Map(pattern, () => Results.NotFound());
            app.Map(ProtectedResource.Path, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.AuthorizationServerPath, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.OpenIdConfigurationPath, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.RegisterPath, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.AuthorizePath, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.TokenPath, () => Results.NotFound());
            app.Map(McpOAuthEndpoints.RevokePath, () => Results.NotFound());
            return null;
        }

        // Map RFC-compliant OAuth 2.1 endpoints (metadata, registration, authorize, token, revoke)
        app.MapMcpOAuth();

        return app.MapMcp(pattern)
            .RequireRateLimiting(RateLimitPolicy)
            .RequireAuthorization(policy => policy
                .AddAuthenticationSchemes(McpTokenDefaults.AuthenticationScheme)
                .RequireAuthenticatedUser());
    }
}
