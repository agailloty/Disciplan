using Disciplaner.Mcp.McpAuth;
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

        // PAT authentication — additive scheme; the JWT bearer default is untouched.
        services.AddAuthentication()
            .AddScheme<McpTokenAuthenticationOptions, McpTokenAuthenticationHandler>(
                McpTokenDefaults.AuthenticationScheme, _ => { });
        services.AddScoped<McpTokenService>();

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
        })
        .WithHttpTransport(options => options.Stateless = true)
        .WithToolsFromAssembly(typeof(DependencyInjection).Assembly);

        return services;
    }

    /// <summary>
    /// Maps the MCP Streamable HTTP endpoint, authenticated with a Disciplaner PAT.
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
            return null;
        }

        return app.MapMcp(pattern)
            .RequireRateLimiting(RateLimitPolicy)
            .RequireAuthorization(policy => policy
                .AddAuthenticationSchemes(McpTokenDefaults.AuthenticationScheme)
                .RequireAuthenticatedUser());
    }
}
