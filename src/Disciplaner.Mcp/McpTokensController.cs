using Disciplaner.Mcp.McpAuth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Disciplaner.Mcp;

/// <summary>
/// Management of the current user's MCP personal access tokens (JWT-authenticated REST API).
/// The raw token value is only returned by the create endpoint, never afterwards.
/// </summary>
[ApiController]
[Authorize]
public sealed class McpTokensController : ControllerBase
{
    private readonly McpTokenService _tokens;

    public McpTokensController(McpTokenService tokens) => _tokens = tokens;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    public sealed record McpTokenDto(
        Guid Id, string Name, string Scopes,
        DateTime CreatedAt, DateTime? LastUsedAt, DateTime? RevokedAt, DateTime? ExpiresAt);

    public sealed record CreateMcpTokenRequest(string Name, string Scopes);

    public sealed record CreateMcpTokenResponse(Guid Id, string Name, string Scopes, string Token);

    [HttpGet("api/me/mcp-tokens")]
    [ProducesResponseType(typeof(IReadOnlyList<McpTokenDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var tokens = await _tokens.ListAsync(UserId, ct);
        return Ok(tokens.Select(ToDto).ToList());
    }

    [HttpPost("api/me/mcp-tokens")]
    [ProducesResponseType(typeof(CreateMcpTokenResponse), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(CreateMcpTokenRequest request, CancellationToken ct)
    {
        var (token, raw) = await _tokens.CreateAsync(UserId, request.Name, request.Scopes, ct);
        var response = new CreateMcpTokenResponse(token.Id, token.Name, token.Scopes, raw);
        return CreatedAtAction(nameof(List), response);
    }

    [HttpDelete("api/me/mcp-tokens/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Revoke(Guid id, CancellationToken ct)
    {
        await _tokens.RevokeAsync(UserId, id, ct);
        return NoContent();
    }

    private static McpTokenDto ToDto(Disciplaner.Domain.Entities.McpToken token) => new(
        token.Id, token.Name, token.Scopes,
        token.CreatedAt, token.LastUsedAt, token.RevokedAt, token.ExpiresAt);
}
