using System.Security.Claims;
using Disciplaner.Application.DTOs.SavedView;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class SavedViewsController : ControllerBase
{
    private readonly ISavedViewService _service;

    public SavedViewsController(ISavedViewService service) => _service = service;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet("api/saved-views")]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _service.GetByUserAsync(UserId, ct));

    [HttpPost("api/saved-views")]
    public async Task<IActionResult> Create(CreateSavedViewRequest request, CancellationToken ct)
    {
        try
        {
            var view = await _service.CreateAsync(UserId, request, ct);
            return CreatedAtAction(nameof(Execute), new { viewId = view.Id }, view);
        }
        catch (Exception ex) when (ex is ArgumentException or ArgumentOutOfRangeException)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPut("api/saved-views/{viewId:guid}")]
    public async Task<IActionResult> Update(Guid viewId, UpdateSavedViewRequest request, CancellationToken ct)
    {
        try { return Ok(await _service.UpdateAsync(viewId, UserId, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex) when (ex is ArgumentException or ArgumentOutOfRangeException)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpDelete("api/saved-views/{viewId:guid}")]
    public async Task<IActionResult> Delete(Guid viewId, CancellationToken ct)
    {
        try
        {
            await _service.DeleteAsync(viewId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    [HttpGet("api/saved-views/{viewId:guid}/tickets", Name = nameof(Execute))]
    public async Task<IActionResult> Execute(Guid viewId, CancellationToken ct)
    {
        try { return Ok(await _service.ExecuteAsync(viewId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }
}
