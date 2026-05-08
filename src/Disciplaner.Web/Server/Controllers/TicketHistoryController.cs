using System.Security.Claims;
using Disciplaner.Application.DTOs.Activity;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
[Route("api/tickets/{ticketId:guid}/history")]
public sealed class TicketHistoryController : ControllerBase
{
    private readonly ITicketHistoryService _history;

    public TicketHistoryController(ITicketHistoryService history) => _history = history;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<TicketHistoryEntryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Get(Guid ticketId, CancellationToken ct = default)
    {
        try
        {
            var entries = await _history.GetByTicketAsync(ticketId, UserId, ct);
            return Ok(entries);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }
}
