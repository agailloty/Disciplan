using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

/// <summary>
/// Public iCalendar feed endpoint — no authentication required.
/// The opaque token in the URL acts as the bearer secret.
/// </summary>
[ApiController]
public sealed class ICalController : ControllerBase
{
    private readonly ICalendarService _calendar;

    public ICalController(ICalendarService calendar) => _calendar = calendar;

    /// <summary>
    /// Returns an iCalendar (RFC 5545) feed for the given subscription token.
    /// Calendar clients (Google Calendar, Outlook, Apple Calendar) poll this URL periodically.
    /// </summary>
    [HttpGet("/ical/{token}")]
    [ResponseCache(Duration = 0, NoStore = true)]
    public async Task<IActionResult> GetFeed(string token, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(token) || token.Length > 64)
            return NotFound();

        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var ical = await _calendar.BuildICalFeedAsync(token, baseUrl, ct);

        if (ical is null)
            return NotFound();

        return Content(ical, "text/calendar; charset=utf-8");
    }
}
