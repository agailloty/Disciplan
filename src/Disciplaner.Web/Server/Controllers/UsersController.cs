using Disciplaner.Application.DTOs.User;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Identity;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class UsersController : ControllerBase
{
    private readonly IUserRepository _users;
    private readonly UserManager<ApplicationUser> _userManager;

    public UsersController(IUserRepository users, UserManager<ApplicationUser> userManager)
    {
        _users = users;
        _userManager = userManager;
    }

    [HttpGet("api/users")]
    [ProducesResponseType(typeof(IReadOnlyList<UserSummaryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var users = await _users.GetAllAsync(ct);
        var dtos = users
            .Where(u => u.IsActive)
            .Select(u => new UserSummaryDto(u.Id, u.DisplayName, u.Email))
            .ToList();
        return Ok(dtos);
    }

    [HttpPut("api/users/me/display-name")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateDisplayName([FromBody] UpdateDisplayNameRequest request)
    {
        var user = await _userManager.GetUserAsync(User);
        if (user is null) return Unauthorized();

        user.DisplayName = request.DisplayName.Trim();
        var result = await _userManager.UpdateAsync(user);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        return NoContent();
    }
}
