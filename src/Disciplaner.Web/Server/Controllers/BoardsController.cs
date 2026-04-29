using System.Security.Claims;
using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/boards")]
[Authorize]
public sealed class BoardsController : ControllerBase
{
    private readonly IBoardService _boards;

    public BoardsController(IBoardService boards) => _boards = boards;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<BoardSummaryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var boards = await _boards.GetAllByUserAsync(UserId, ct);
        return Ok(boards);
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(BoardDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var board = await _boards.GetByIdAsync(id, UserId, ct);
        return board is null ? NotFound() : Ok(board);
    }

    [HttpPost]
    [ProducesResponseType(typeof(BoardDetailDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(CreateBoardRequest request, CancellationToken ct)
    {
        var board = await _boards.CreateAsync(UserId, request, ct);
        return CreatedAtAction(nameof(GetById), new { id = board.Id }, board);
    }

    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(BoardDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, UpdateBoardRequest request, CancellationToken ct)
    {
        try
        {
            var board = await _boards.UpdateAsync(id, UserId, request, ct);
            return Ok(board);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        try
        {
            await _boards.DeleteAsync(id, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
    }
}
