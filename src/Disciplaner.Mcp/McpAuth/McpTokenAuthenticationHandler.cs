using Disciplaner.Domain.Common;
using Disciplaner.Domain.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Security.Claims;
using System.Text.Encodings.Web;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// Authenticates MCP requests bearing a personal access token (Authorization: Bearer dcp_...).
/// On success, builds the same ClaimsPrincipal shape as the JWT flow (ClaimTypes.NameIdentifier),
/// so the existing per-project role matrix applies without modification.
/// </summary>
public sealed class McpTokenAuthenticationHandler(
    IOptionsMonitor<McpTokenAuthenticationOptions> options,
    ILoggerFactory logger,
    UrlEncoder encoder)
    : AuthenticationHandler<McpTokenAuthenticationOptions>(options, logger, encoder)
{
    /// <summary>Minimum delay between two LastUsedAt flushes for the same token.</summary>
    public static readonly TimeSpan LastUsedFlushInterval = TimeSpan.FromMinutes(5);

    /// <summary>MemoryCache key prefix gating LastUsedAt writes: prefix + token id.</summary>
    public const string LastUsedCacheKeyPrefix = "mcp-lastuse-";

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var authorization = Request.Headers.Authorization.ToString();
        if (string.IsNullOrEmpty(authorization))
            return AuthenticateResult.NoResult();

        // Bearer tokens that are not Disciplaner PATs (e.g. the app's JWT) are not
        // accepted on /mcp: fall through to the anonymous result instead of failing
        // with an obscure hash-mismatch error.
        if (!authorization.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            return AuthenticateResult.NoResult();

        var rawToken = authorization["Bearer ".Length..].Trim();
        if (rawToken.Length <= McpTokenSecurity.RawPrefix.Length)
            return AuthenticateResult.NoResult();

        var hash = McpTokenSecurity.HashOf(rawToken);
        if (hash is null)
            return AuthenticateResult.NoResult();

        var uow = Context.RequestServices.GetRequiredService<IUnitOfWork>();
        var token = await uow.McpTokens.GetByHashAsync(hash, Context.RequestAborted);
        var now = DateTime.UtcNow;

        if (token is null || !token.IsActive(now))
            return AuthenticateResult.Fail("Invalid or revoked MCP token.");

        // Same claim the JWT flow provides; services resolve the user id from it.
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, token.UserId),
            new Claim(McpTokenDefaults.ScopesClaimType, token.Scopes),
            new Claim(McpTokenDefaults.TokenNameClaimType, token.Name)
        };
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);

        // LastUsedAt telemetry: the UPDATE is persisted at most once per token per 5-minute
        // sliding window. The token row itself is still loaded on every request, so
        // revocation stays immediate; only the LastUsedAt write is deferred.
        token.RecordUse(now);

        var cache = Context.RequestServices.GetService<IMemoryCache>();
        var lastUseKey = cache is null ? null : LastUsedCacheKeyPrefix + token.Id;
        if (lastUseKey is null || !cache!.TryGetValue(lastUseKey, out _))
        {
            await uow.SaveChangesAsync(Context.RequestAborted);
            cache?.Set(lastUseKey!, now, new MemoryCacheEntryOptions
            {
                SlidingExpiration = LastUsedFlushInterval
            });
        }

        return AuthenticateResult.Success(new AuthenticationTicket(principal, Scheme.Name));
    }
}
