using Disciplaner.Application.DTOs.Auth;
using Disciplaner.Infrastructure.Identity;
using Disciplaner.Web.Server.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

/// <summary>
/// First-run setup: available only when no users exist in the database.
/// Once the first admin is created these endpoints return 404.
/// </summary>
[ApiController]
[Route("api/setup")]
public sealed class SetupController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly JwtTokenService _tokenService;

    public SetupController(UserManager<ApplicationUser> userManager, JwtTokenService tokenService)
    {
        _userManager = userManager;
        _tokenService = tokenService;
    }

    /// <summary>Returns whether the application requires first-run setup.</summary>
    [HttpGet("status")]
    [ProducesResponseType(typeof(SetupStatusResponse), StatusCodes.Status200OK)]
    public IActionResult GetStatus()
    {
        var setupRequired = !_userManager.Users.Any();
        return Ok(new SetupStatusResponse(setupRequired));
    }

    /// <summary>Creates the first administrator account. Returns 404 when setup is already complete.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Setup(SetupRequest request)
    {
        // Only available when no users exist
        if (_userManager.Users.Any())
            return NotFound(new { message = "Setup is already complete." });

        if (await _userManager.FindByEmailAsync(request.Email) is not null)
            return Conflict(new { message = "An account with this email already exists." });

        var admin = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            DisplayName = request.DisplayName,
            EmailConfirmed = true,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(admin, request.Password);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        await _userManager.AddToRoleAsync(admin, "Admin");

        var roles = await _userManager.GetRolesAsync(admin);
        var (token, expiresAt) = _tokenService.GenerateToken(admin, roles);
        return Ok(new AuthResponse(token, admin.Email!, admin.DisplayName, roles.ToList().AsReadOnly(), expiresAt));
    }
}
