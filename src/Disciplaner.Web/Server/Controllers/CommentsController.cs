using System.Security.Claims;
using Disciplaner.Application.DTOs.Comment;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class CommentsController : ControllerBase
{
    private readonly ICommentService _comments;

    public CommentsController(ICommentService comments) => _comments = comments;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    private bool IsAdmin => User.IsInRole("Admin");

    // GET api/cards/{cardId}/comments
    [HttpGet("api/cards/{cardId:guid}/comments")]
    [ProducesResponseType(typeof(IReadOnlyList<CommentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByCard(Guid cardId, CancellationToken ct)
    {
        try
        {
            var comments = await _comments.GetByCardAsync(cardId, UserId, ct);
            return Ok(comments);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // POST api/cards/{cardId}/comments
    [HttpPost("api/cards/{cardId:guid}/comments")]
    [ProducesResponseType(typeof(CommentDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Create(Guid cardId, CreateCommentRequest request, CancellationToken ct)
    {
        try
        {
            var comment = await _comments.CreateAsync(cardId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByCard), new { cardId }, comment);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // PUT api/comments/{commentId}
    [HttpPut("api/comments/{commentId:guid}")]
    [ProducesResponseType(typeof(CommentDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid commentId, UpdateCommentRequest request, CancellationToken ct)
    {
        try
        {
            var comment = await _comments.UpdateAsync(commentId, UserId, request, ct);
            return Ok(comment);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // DELETE api/comments/{commentId}
    [HttpDelete("api/comments/{commentId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid commentId, CancellationToken ct)
    {
        try
        {
            await _comments.DeleteAsync(commentId, UserId, IsAdmin, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // GET api/tickets/{ticketId}/comments
    [HttpGet("api/tickets/{ticketId:guid}/comments")]
    [ProducesResponseType(typeof(IReadOnlyList<CommentDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetByTicket(Guid ticketId, CancellationToken ct)
    {
        try { return Ok(await _comments.GetByTicketAsync(ticketId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }

    // POST api/tickets/{ticketId}/comments
    [HttpPost("api/tickets/{ticketId:guid}/comments")]
    [ProducesResponseType(typeof(CommentDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateForTicket(Guid ticketId, CreateCommentRequest request, CancellationToken ct)
    {
        try
        {
            var comment = await _comments.CreateForTicketAsync(ticketId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByTicket), new { ticketId }, comment);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
    }
}
