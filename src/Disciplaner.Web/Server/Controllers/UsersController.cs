using Disciplaner.Application.DTOs.User;
using Disciplaner.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class UsersController : ControllerBase
{
    private readonly IUserRepository _users;

    public UsersController(IUserRepository users) => _users = users;

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
}
