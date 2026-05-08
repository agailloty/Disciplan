using System.Security.Claims;
using Disciplaner.Application.DTOs.Activity;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
[Route("api/activity")]
public sealed class ActivityController : ControllerBase
{
    private readonly IActivityService _activity;

    public ActivityController(IActivityService activity) => _activity = activity;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet("recent")]
    [ProducesResponseType(typeof(IReadOnlyList<ActivityItemDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetRecent([FromQuery] int limit = 20, CancellationToken ct = default)
    {
        var items = await _activity.GetRecentActivityAsync(UserId, Math.Clamp(limit, 1, 50), ct);
        return Ok(items);
    }

    [HttpGet("grouped")]
    [ProducesResponseType(typeof(IReadOnlyList<TicketActivityGroupDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetGrouped([FromQuery] int limit = 20, CancellationToken ct = default)
    {
        var groups = await _activity.GetRecentGroupedAsync(UserId, Math.Clamp(limit, 1, 50), ct);
        return Ok(groups);
    }
}
