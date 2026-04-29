using System.Security.Claims;
using Disciplaner.Application.DTOs.Column;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class ColumnsController : ControllerBase
{
    private readonly IColumnService _columns;

    public ColumnsController(IColumnService columns) => _columns = columns;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    // POST api/boards/{boardId}/columns
    [HttpPost("api/boards/{boardId:guid}/columns")]
    [ProducesResponseType(typeof(ColumnDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(Guid boardId, CreateColumnRequest request, CancellationToken ct)
    {
        try
        {
            var column = await _columns.CreateAsync(boardId, UserId, request, ct);
            return CreatedAtAction(nameof(GetById), new { columnId = column.Id }, column);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    // GET api/columns/{columnId}
    [HttpGet("api/columns/{columnId:guid}")]
    [ProducesResponseType(typeof(ColumnDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid columnId, CancellationToken ct)
    {
        var column = await _columns.GetByIdAsync(columnId, UserId, ct);
        return column is null ? NotFound() : Ok(column);
    }

    // PUT api/columns/{columnId}
    [HttpPut("api/columns/{columnId:guid}")]
    [ProducesResponseType(typeof(ColumnDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid columnId, UpdateColumnRequest request, CancellationToken ct)
    {
        try
        {
            var column = await _columns.UpdateAsync(columnId, UserId, request, ct);
            return Ok(column);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    // DELETE api/columns/{columnId}
    [HttpDelete("api/columns/{columnId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid columnId, CancellationToken ct)
    {
        try
        {
            await _columns.DeleteAsync(columnId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
    }
}
