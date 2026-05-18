using System.Security.Claims;
using Disciplaner.Application.DTOs.Member;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/projects/{projectId:guid}/members")]
[Authorize]
public sealed class ProjectMembersController : ControllerBase
{
    private readonly IProjectMemberService _members;

    public ProjectMembersController(IProjectMemberService members) => _members = members;

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("sub")
        ?? throw new InvalidOperationException("User ID claim not found.");

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<MemberDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMembers(Guid projectId, CancellationToken ct)
    {
        try
        {
            var result = await _members.GetMembersAsync(projectId, UserId, ct);
            return Ok(result);
        }
        catch (NotFoundException) { return NotFound(); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpPost]
    [ProducesResponseType(typeof(MemberDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> AddMember(Guid projectId, [FromBody] AddMemberRequest request, CancellationToken ct)
    {
        try
        {
            var member = await _members.AddMemberAsync(projectId, UserId, request, ct);
            return CreatedAtAction(nameof(GetMembers), new { projectId }, member);
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpPut("{userId}")]
    [ProducesResponseType(typeof(MemberDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdateRole(Guid projectId, string userId,
        [FromBody] UpdateMemberRoleRequest request, CancellationToken ct)
    {
        try
        {
            var member = await _members.UpdateMemberRoleAsync(projectId, userId, UserId, request, ct);
            return Ok(member);
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }

    [HttpDelete("{userId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RemoveMember(Guid projectId, string userId, CancellationToken ct)
    {
        try
        {
            await _members.RemoveMemberAsync(projectId, userId, UserId, ct);
            return NoContent();
        }
        catch (NotFoundException e) { return NotFound(e.Message); }
        catch (ForbiddenException) { return Forbid(); }
    }
}
