using System.Security.Claims;
using Disciplaner.Application.DTOs.Attachment;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class AttachmentsController : ControllerBase
{
    private readonly IAttachmentService _attachments;

    public AttachmentsController(IAttachmentService attachments) => _attachments = attachments;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    private bool IsAdmin => User.IsInRole("Admin");

    // ── Queries ───────────────────────────────────────────────────────────────

    // GET api/tickets/{ticketId}/attachments
    [HttpGet("api/tickets/{ticketId:guid}/attachments")]
    [ProducesResponseType(typeof(IReadOnlyList<AttachmentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByTicket(Guid ticketId, CancellationToken ct)
    {
        try { return Ok(await _attachments.GetByTicketAsync(ticketId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    // GET api/comments/{commentId}/attachments
    [HttpGet("api/comments/{commentId:guid}/attachments")]
    [ProducesResponseType(typeof(IReadOnlyList<AttachmentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByComment(Guid commentId, CancellationToken ct)
    {
        try { return Ok(await _attachments.GetByCommentAsync(commentId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    // GET api/boards/{boardId}/attachments
    [HttpGet("api/boards/{boardId:guid}/attachments")]
    [ProducesResponseType(typeof(IReadOnlyList<AttachmentDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetByBoard(Guid boardId, CancellationToken ct)
    {
        try { return Ok(await _attachments.GetByBoardAsync(boardId, UserId, ct)); }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    // ── Uploads ───────────────────────────────────────────────────────────────

    // POST api/tickets/{ticketId}/attachments
    [HttpPost("api/tickets/{ticketId:guid}/attachments")]
    [ProducesResponseType(typeof(AttachmentDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UploadForTicket(Guid ticketId, IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest("No file provided.");

        try
        {
            var request = new UploadFileRequest(file.OpenReadStream(), file.FileName, file.ContentType, file.Length);
            var dto = await _attachments.UploadForTicketAsync(ticketId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByTicket), new { ticketId }, dto);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
        catch (ArgumentException ex) { return BadRequest(new { error = ex.Message }); }
    }

    // POST api/comments/{commentId}/attachments
    [HttpPost("api/comments/{commentId:guid}/attachments")]
    [ProducesResponseType(typeof(AttachmentDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UploadForComment(Guid commentId, IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest("No file provided.");

        try
        {
            var request = new UploadFileRequest(file.OpenReadStream(), file.FileName, file.ContentType, file.Length);
            var dto = await _attachments.UploadForCommentAsync(commentId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByComment), new { commentId }, dto);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
        catch (ArgumentException ex) { return BadRequest(new { error = ex.Message }); }
    }

    // POST api/boards/{boardId}/attachments
    [HttpPost("api/boards/{boardId:guid}/attachments")]
    [ProducesResponseType(typeof(AttachmentDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UploadForBoard(Guid boardId, IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest("No file provided.");

        try
        {
            var request = new UploadFileRequest(file.OpenReadStream(), file.FileName, file.ContentType, file.Length);
            var dto = await _attachments.UploadForBoardAsync(boardId, UserId, request, ct);
            return CreatedAtAction(nameof(GetByBoard), new { boardId }, dto);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
        catch (ArgumentException ex) { return BadRequest(new { error = ex.Message }); }
    }

    // ── Download ──────────────────────────────────────────────────────────────

    // GET api/attachments/{id}/download
    [HttpGet("api/attachments/{id:guid}/download")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Download(Guid id, CancellationToken ct)
    {
        try
        {
            var info = await _attachments.GetDownloadInfoAsync(id, UserId, ct);

            if (!System.IO.File.Exists(info.AbsolutePath))
                return NotFound();

            return PhysicalFile(info.AbsolutePath, info.ContentType, info.FileName, enableRangeProcessing: true);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    // ── Delete ────────────────────────────────────────────────────────────────

    // DELETE api/attachments/{id}
    [HttpDelete("api/attachments/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        try
        {
            await _attachments.DeleteAsync(id, UserId, IsAdmin, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }
}
