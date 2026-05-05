using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/labels")]
[Authorize]
public sealed class LabelsController : ControllerBase
{
    private readonly ILabelService _labels;

    public LabelsController(ILabelService labels) => _labels = labels;

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<LabelDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
        => Ok(await _labels.GetAllAsync(ct));

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(LabelDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var label = await _labels.GetByIdAsync(id, ct);
        return label is null ? NotFound() : Ok(label);
    }

    [HttpGet("{id:guid}/items")]
    [ProducesResponseType(typeof(LabelItemsDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetItems(Guid id, CancellationToken ct)
    {
        var result = await _labels.GetItemsByIdAsync(id, ct);
        return result is null ? NotFound() : Ok(result);
    }

    [HttpPost]
    [ProducesResponseType(typeof(LabelDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(CreateLabelRequest request, CancellationToken ct)
    {
        var label = await _labels.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = label.Id }, label);
    }

    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(LabelDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, UpdateLabelRequest request, CancellationToken ct)
    {
        try { return Ok(await _labels.UpdateAsync(id, request, ct)); }
        catch (NotFoundException) { return NotFound(); }
    }

    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        try { await _labels.DeleteAsync(id, ct); return NoContent(); }
        catch (NotFoundException) { return NotFound(); }
    }

    // ── Ticket attachment ──────────────────────────────────────────────────────

    [HttpPost("{labelId:guid}/tickets/{ticketId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AttachTicket(Guid labelId, Guid ticketId, CancellationToken ct)
    {
        await _labels.AttachToTicketAsync(labelId, ticketId, ct);
        return NoContent();
    }

    [HttpDelete("{labelId:guid}/tickets/{ticketId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DetachTicket(Guid labelId, Guid ticketId, CancellationToken ct)
    {
        await _labels.DetachFromTicketAsync(labelId, ticketId, ct);
        return NoContent();
    }

    // ── Board attachment ───────────────────────────────────────────────────────

    [HttpPost("{labelId:guid}/boards/{boardId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AttachBoard(Guid labelId, Guid boardId, CancellationToken ct)
    {
        await _labels.AttachToBoardAsync(labelId, boardId, ct);
        return NoContent();
    }

    [HttpDelete("{labelId:guid}/boards/{boardId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DetachBoard(Guid labelId, Guid boardId, CancellationToken ct)
    {
        await _labels.DetachFromBoardAsync(labelId, boardId, ct);
        return NoContent();
    }
}
