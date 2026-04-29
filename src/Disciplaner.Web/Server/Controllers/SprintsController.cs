using System.Security.Claims;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class SprintsController : ControllerBase
{
    private readonly ISprintService _sprints;

    public SprintsController(ISprintService sprints) => _sprints = sprints;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet("api/projects/{projectId:guid}/sprints")]
    [ProducesResponseType(typeof(IReadOnlyList<SprintDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByProject(Guid projectId, CancellationToken ct)
    {
        try { return Ok(await _sprints.GetByProjectAsync(projectId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpPost("api/projects/{projectId:guid}/sprints")]
    [ProducesResponseType(typeof(SprintDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(Guid projectId, CreateSprintRequest request, CancellationToken ct)
    {
        try
        {
            var sprint = await _sprints.CreateAsync(projectId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByProject), new { projectId }, sprint);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpPut("api/sprints/{sprintId:guid}")]
    [ProducesResponseType(typeof(SprintDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> Update(Guid sprintId, UpdateSprintRequest request, CancellationToken ct)
    {
        try { return Ok(await _sprints.UpdateAsync(sprintId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpPut("api/sprints/{sprintId:guid}/start")]
    [ProducesResponseType(typeof(SprintDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> Start(Guid sprintId, StartSprintRequest request, CancellationToken ct)
    {
        try { return Ok(await _sprints.StartAsync(sprintId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpPut("api/sprints/{sprintId:guid}/close")]
    [ProducesResponseType(typeof(SprintDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> Close(Guid sprintId, CancellationToken ct)
    {
        try { return Ok(await _sprints.CloseAsync(sprintId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpDelete("api/sprints/{sprintId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> Delete(Guid sprintId, CancellationToken ct)
    {
        try
        {
            await _sprints.DeleteAsync(sprintId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }
}
