using System.Security.Claims;
using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/boards/{boardId:guid}/members")]
[Authorize]
public sealed class BoardMembersController : ControllerBase
{
    private readonly IBoardMemberService _members;

    public BoardMembersController(IBoardMemberService members) => _members = members;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<MemberDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMembers(Guid boardId, CancellationToken ct)
    {
        try
        {
            var result = await _members.GetMembersAsync(boardId, UserId, ct);
            return Ok(result);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpPost]
    [ProducesResponseType(typeof(MemberDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> AddMember(Guid boardId, [FromBody] AddMemberRequest request, CancellationToken ct)
    {
        try
        {
            var member = await _members.AddMemberAsync(boardId, UserId, request, ct);
            return CreatedAtAction(nameof(GetMembers), new { boardId }, member);
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpPut("{userId}")]
    [ProducesResponseType(typeof(MemberDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateRole(Guid boardId, string userId,
        [FromBody] UpdateMemberRoleRequest request, CancellationToken ct)
    {
        try
        {
            var member = await _members.UpdateMemberRoleAsync(boardId, userId, UserId, request, ct);
            return Ok(member);
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpDelete("{userId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RemoveMember(Guid boardId, string userId, CancellationToken ct)
    {
        try
        {
            await _members.RemoveMemberAsync(boardId, userId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }
}
