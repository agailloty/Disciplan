using System.Security.Claims;
using Disciplaner.Application.DTOs.Card;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class CardsController : ControllerBase
{
    private readonly ICardService _cards;

    public CardsController(ICardService cards) => _cards = cards;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    // POST api/columns/{columnId}/cards
    [HttpPost("api/columns/{columnId:guid}/cards")]
    [ProducesResponseType(typeof(CardDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create(Guid columnId, CreateCardRequest request, CancellationToken ct)
    {
        try
        {
            var card = await _cards.CreateAsync(columnId, UserId, request, ct);
            return CreatedAtAction(nameof(GetById), new { cardId = card.Id }, card);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    // GET api/cards/{cardId}
    [HttpGet("api/cards/{cardId:guid}")]
    [ProducesResponseType(typeof(CardDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid cardId, CancellationToken ct)
    {
        var card = await _cards.GetByIdAsync(cardId, UserId, ct);
        return card is null ? NotFound() : Ok(card);
    }

    // PUT api/cards/{cardId}
    [HttpPut("api/cards/{cardId:guid}")]
    [ProducesResponseType(typeof(CardDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid cardId, UpdateCardRequest request, CancellationToken ct)
    {
        try
        {
            var card = await _cards.UpdateAsync(cardId, UserId, request, ct);
            return Ok(card);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    // PUT api/cards/{cardId}/move
    [HttpPut("api/cards/{cardId:guid}/move")]
    [ProducesResponseType(typeof(CardDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Move(Guid cardId, MoveCardRequest request, CancellationToken ct)
    {
        try
        {
            var card = await _cards.MoveAsync(cardId, UserId, request, ct);
            return Ok(card);
        }
        catch (NotFoundException) { return NotFound(); }
    }

    // DELETE api/cards/{cardId}
    [HttpDelete("api/cards/{cardId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid cardId, CancellationToken ct)
    {
        try
        {
            await _cards.DeleteAsync(cardId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException) { return NotFound(); }
    }
}
