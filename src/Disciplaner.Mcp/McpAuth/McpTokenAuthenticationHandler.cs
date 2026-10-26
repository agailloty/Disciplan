using Disciplaner.Domain.Common;
using Disciplaner.Domain.Interfaces;
using Microsoft.AspNetCore.Authentication;
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

        token.RecordUse(now);
        await uow.SaveChangesAsync(Context.RequestAborted);

        return AuthenticateResult.Success(new AuthenticationTicket(principal, Scheme.Name));
    }
}
