using System.Security.Claims;
using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Exceptions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/projects")]
[Authorize]
public sealed class ProjectsController : ControllerBase
{
    private readonly IProjectService _projects;

    public ProjectsController(IProjectService projects) => _projects = projects;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<ProjectSummaryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _projects.GetAllByUserAsync(UserId, ct));

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ProjectDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        try
        {
            var project = await _projects.GetByIdAsync(id, UserId, ct);
            return project is null ? NotFound() : Ok(project);
        }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpPost]
    [ProducesResponseType(typeof(ProjectDetailDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create(CreateProjectRequest request, CancellationToken ct)
    {
        try
        {
            var project = await _projects.CreateAsync(UserId, request, ct);
            return CreatedAtAction(nameof(GetById), new { id = project.Id }, project);
        }
        catch (Exception ex) when (ex is DomainException or InvalidOperationException)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(ProjectDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, UpdateProjectRequest request, CancellationToken ct)
    {
        try { return Ok(await _projects.UpdateAsync(id, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        try
        {
            await _projects.DeleteAsync(id, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpPost("{projectId:guid}/statuses")]
    [ProducesResponseType(typeof(TicketStatusDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> AddStatus(Guid projectId, CreateTicketStatusRequest request, CancellationToken ct)
    {
        try
        {
            var status = await _projects.AddStatusAsync(projectId, UserId, request, ct);
            return CreatedAtAction(nameof(GetById), new { id = projectId }, status);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpPut("{projectId:guid}/statuses/{statusId:guid}")]
    [ProducesResponseType(typeof(TicketStatusDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateStatus(
        Guid projectId, Guid statusId, UpdateTicketStatusRequest request, CancellationToken ct)
    {
        try { return Ok(await _projects.UpdateStatusAsync(projectId, statusId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }

    [HttpDelete("{projectId:guid}/statuses/{statusId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteStatus(Guid projectId, Guid statusId, CancellationToken ct)
    {
        try
        {
            await _projects.DeleteStatusAsync(projectId, statusId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (DomainException ex) { return BadRequest(ex.Message); }
    }
}
