using System.Security.Claims;
using Disciplaner.Application.DTOs.Calendar;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

/// <summary>
/// Manages the user's personal calendar subscription token.
/// All endpoints require authentication.
/// </summary>
[ApiController]
[Route("api/calendar")]
[Authorize]
public sealed class CalendarController : ControllerBase
{
    private readonly ICalendarService _calendar;

    public CalendarController(ICalendarService calendar) => _calendar = calendar;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    /// <summary>Returns the current token, or 404 if none has been generated yet.</summary>
    [HttpGet("token")]
    [ProducesResponseType(typeof(CalendarTokenDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetToken(CancellationToken ct)
    {
        var token = await _calendar.GetTokenAsync(UserId, ct);
        return token is null ? NotFound() : Ok(token);
    }

    /// <summary>Creates or replaces the user's calendar token.</summary>
    [HttpPost("token")]
    [ProducesResponseType(typeof(CalendarTokenDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GenerateToken(CancellationToken ct)
    {
        var token = await _calendar.GenerateTokenAsync(UserId, ct);
        return Ok(token);
    }

    /// <summary>Revokes the user's calendar token, invalidating all existing subscription URLs.</summary>
    [HttpDelete("token")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RevokeToken(CancellationToken ct)
    {
        await _calendar.RevokeTokenAsync(UserId, ct);
        return NoContent();
    }
}
