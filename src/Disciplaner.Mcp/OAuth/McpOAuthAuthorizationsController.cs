using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Mcp.OAuth;

/// <summary>
/// Management of the current user's granted OAuth 2.1 client authorizations (JWT-authenticated REST API).
/// </summary>
[ApiController]
[Authorize]
public sealed class McpOAuthAuthorizationsController : ControllerBase
{
    private readonly McpOAuthService _oauth;

    public McpOAuthAuthorizationsController(McpOAuthService oauth) => _oauth = oauth;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet("api/me/oauth-authorizations")]
    [ProducesResponseType(typeof(IReadOnlyList<McpOAuthModels.OAuthAuthorizationDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var authorizations = await _oauth.ListUserAuthorizationsAsync(UserId, ct);
        return Ok(authorizations);
    }

    [HttpDelete("api/me/oauth-authorizations/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Revoke(Guid id, CancellationToken ct)
    {
        var revoked = await _oauth.RevokeUserAuthorizationAsync(UserId, id, ct);
        if (!revoked)
            return NotFound();

        return NoContent();
    }
}
