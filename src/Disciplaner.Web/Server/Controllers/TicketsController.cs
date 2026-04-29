using System.Security.Claims;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class TicketsController : ControllerBase
{
    private readonly ITicketService _tickets;

    public TicketsController(ITicketService tickets) => _tickets = tickets;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet("api/projects/{projectId:guid}/tickets/backlog")]
    [ProducesResponseType(typeof(IReadOnlyList<TicketDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBacklog(Guid projectId, CancellationToken ct)
    {
        try { return Ok(await _tickets.GetBacklogAsync(projectId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpPost("api/projects/{projectId:guid}/tickets")]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(Guid projectId, CreateTicketRequest request, CancellationToken ct)
    {
        try
        {
            var ticket = await _tickets.CreateAsync(projectId, UserId, request, ct);
            return CreatedAtAction(nameof(GetById), new { ticketId = ticket.Id }, ticket);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex) when (ex is DomainException or ArgumentException or ArgumentOutOfRangeException)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("api/sprints/{sprintId:guid}/tickets")]
    [ProducesResponseType(typeof(IReadOnlyList<TicketDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBySprint(Guid sprintId, CancellationToken ct)
    {
        try { return Ok(await _tickets.GetBySprintAsync(sprintId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpGet("api/tickets/{ticketId:guid}", Name = nameof(GetById))]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetById(Guid ticketId, CancellationToken ct)
    {
        try
        {
            var ticket = await _tickets.GetByIdAsync(ticketId, UserId, ct);
            return ticket is null ? NotFound() : Ok(ticket);
        }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // GET api/tickets/by-ref/{projectKey}/{ticketNumber}  → e.g. /api/tickets/by-ref/GAI/3
    [HttpGet("api/tickets/by-ref/{projectKey}/{ticketNumber:int}")]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByRef(string projectKey, int ticketNumber, CancellationToken ct)
    {
        try
        {
            var ticket = await _tickets.GetByRefAsync(projectKey, ticketNumber, UserId, ct);
            return ticket is null ? NotFound() : Ok(ticket);
        }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpPut("api/tickets/{ticketId:guid}")]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> Update(Guid ticketId, UpdateTicketRequest request, CancellationToken ct)
    {
        try { return Ok(await _tickets.UpdateAsync(ticketId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex) when (ex is DomainException or ArgumentException or ArgumentOutOfRangeException)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("api/tickets/{ticketId:guid}/status")]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> ChangeStatus(Guid ticketId, ChangeTicketStatusRequest request, CancellationToken ct)
    {
        try { return Ok(await _tickets.ChangeStatusAsync(ticketId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpPut("api/tickets/{ticketId:guid}/sprint")]
    [ProducesResponseType(typeof(TicketDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> MoveToSprint(Guid ticketId, MoveTicketToSprintRequest request, CancellationToken ct)
    {
        try { return Ok(await _tickets.MoveToSprintAsync(ticketId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpDelete("api/tickets/{ticketId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Delete(Guid ticketId, CancellationToken ct)
    {
        try
        {
            await _tickets.DeleteAsync(ticketId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }
}
