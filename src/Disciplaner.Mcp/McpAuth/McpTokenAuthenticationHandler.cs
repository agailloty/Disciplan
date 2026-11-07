using Disciplaner.Domain.Common;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Mcp.OAuth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Security.Claims;
using System.Text.Encodings.Web;

namespace Disciplaner.Mcp.McpAuth;

/// <summary>
/// Authenticates MCP requests bearing either:
/// 1. An OAuth 2.1 Access Token (Authorization: Bearer dcp_at_...)
/// 2. A Personal Access Token (Authorization: Bearer dcp_...)
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
    public const string OAuthLastUsedCacheKeyPrefix = "mcp-oauth-lastuse-";

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var authorization = Request.Headers.Authorization.ToString();
        if (string.IsNullOrEmpty(authorization))
            return AuthenticateResult.NoResult();

        if (!authorization.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            return AuthenticateResult.NoResult();

        var rawToken = authorization["Bearer ".Length..].Trim();
        if (string.IsNullOrEmpty(rawToken))
            return AuthenticateResult.NoResult();

        var uow = Context.RequestServices.GetRequiredService<IUnitOfWork>();
        var now = DateTime.UtcNow;

        // ── 1. Check for OAuth 2.1 Access Token (dcp_at_...) ────────────────
        if (rawToken.StartsWith(McpOAuthSecurity.AccessTokenPrefix, StringComparison.Ordinal))
        {
            var tokenHash = McpOAuthSecurity.Sha256(rawToken);
            var oauthToken = await uow.McpOAuth.GetTokenByAccessHashAsync(tokenHash, Context.RequestAborted);

            if (oauthToken is null || !oauthToken.IsAccessTokenActive(now))
                return AuthenticateResult.Fail("Invalid, expired, or revoked MCP OAuth access token.");

            var client = await uow.McpOAuth.GetClientByIdAsync(oauthToken.ClientId, Context.RequestAborted);
            var clientName = client?.ClientName ?? oauthToken.ClientId;

            var oauthClaims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, oauthToken.UserId),
                new Claim(McpTokenDefaults.ScopesClaimType, oauthToken.Scope),
                new Claim(McpTokenDefaults.TokenNameClaimType, clientName),
                new Claim("client_id", oauthToken.ClientId)
            };

            var oauthIdentity = new ClaimsIdentity(oauthClaims, Scheme.Name);
            var oauthPrincipal = new ClaimsPrincipal(oauthIdentity);

            oauthToken.RecordUse(now);
            var cache = Context.RequestServices.GetService<IMemoryCache>();
            var lastUseKey = cache is null ? null : OAuthLastUsedCacheKeyPrefix + oauthToken.Id;
            if (lastUseKey is null || !cache!.TryGetValue(lastUseKey, out _))
            {
                await uow.SaveChangesAsync(Context.RequestAborted);
                cache?.Set(lastUseKey!, now, new MemoryCacheEntryOptions
                {
                    SlidingExpiration = LastUsedFlushInterval
                });
            }

            return AuthenticateResult.Success(new AuthenticationTicket(oauthPrincipal, Scheme.Name));
        }

        // ── 2. Check for Personal Access Token (dcp_...) ─────────────────────
        if (rawToken.Length <= McpTokenSecurity.RawPrefix.Length)
            return AuthenticateResult.NoResult();

        var hash = McpTokenSecurity.HashOf(rawToken);
        if (hash is null)
            return AuthenticateResult.NoResult();

        var token = await uow.McpTokens.GetByHashAsync(hash, Context.RequestAborted);
        if (token is null || !token.IsActive(now))
            return AuthenticateResult.Fail("Invalid or revoked MCP token.");

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, token.UserId),
            new Claim(McpTokenDefaults.ScopesClaimType, token.Scopes),
            new Claim(McpTokenDefaults.TokenNameClaimType, token.Name)
        };
        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);

        token.RecordUse(now);

        var memCache = Context.RequestServices.GetService<IMemoryCache>();
        var patLastUseKey = memCache is null ? null : LastUsedCacheKeyPrefix + token.Id;
        if (patLastUseKey is null || !memCache!.TryGetValue(patLastUseKey, out _))
        {
            await uow.SaveChangesAsync(Context.RequestAborted);
            memCache?.Set(patLastUseKey!, now, new MemoryCacheEntryOptions
            {
                SlidingExpiration = LastUsedFlushInterval
            });
        }

        return AuthenticateResult.Success(new AuthenticationTicket(principal, Scheme.Name));
    }

    /// <summary>
    /// 401 challenge (RFC 9728): points conforming MCP clients at the Protected
    /// Resource Metadata document, which advertises the OAuth 2.1 authorization servers.
    /// </summary>
    protected override Task HandleChallengeAsync(AuthenticationProperties properties)
    {
        Response.StatusCode = StatusCodes.Status401Unauthorized;
        var metadataUrl = $"{Request.Scheme}://{Request.Host}{McpOAuthEndpoints.ProtectedResourcePath}";
        Response.Headers.WWWAuthenticate = $"Bearer resource_metadata=\"{metadataUrl}\"";
        return Task.CompletedTask;
    }
}
