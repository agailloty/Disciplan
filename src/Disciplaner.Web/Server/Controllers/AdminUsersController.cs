using Disciplaner.Application.DTOs.Auth;
using Disciplaner.Application.DTOs.User;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Identity;
using Disciplaner.Web.Server.Identity;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

/// <summary>Admin-only endpoints for managing users and invitations.</summary>
[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public sealed class AdminUsersController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;
    private readonly IUserInvitationRepository _invitations;
    private readonly JwtTokenService _tokenService;

    private static readonly string[] AllowedRoles = ["Admin", "User"];

    public AdminUsersController(
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole> roleManager,
        IUserInvitationRepository invitations,
        JwtTokenService tokenService)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _invitations = invitations;
        _tokenService = tokenService;
    }

    // ── Users ─────────────────────────────────────────────────────────────────

    [HttpGet("users")]
    [ProducesResponseType(typeof(IReadOnlyList<AdminUserDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetUsers()
    {
        var users = _userManager.Users.ToList();
        var dtos = new List<AdminUserDto>(users.Count);
        foreach (var u in users)
        {
            var roles = await _userManager.GetRolesAsync(u);
            dtos.Add(new AdminUserDto(u.Id, u.DisplayName, u.Email!, u.IsActive, u.CreatedAt, roles.ToList().AsReadOnly()));
        }
        return Ok(dtos);
    }

    [HttpPost("users")]
    [ProducesResponseType(typeof(AdminUserDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> CreateUser(CreateUserRequest request)
    {
        if (!AllowedRoles.Contains(request.Role))
            return BadRequest(new { message = $"Role must be one of: {string.Join(", ", AllowedRoles)}." });

        if (await _userManager.FindByEmailAsync(request.Email) is not null)
            return Conflict(new { message = "An account with this email already exists." });

        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            DisplayName = request.DisplayName,
            EmailConfirmed = true,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        await _userManager.AddToRoleAsync(user, request.Role);
        var roles = await _userManager.GetRolesAsync(user);
        var dto = new AdminUserDto(user.Id, user.DisplayName, user.Email!, user.IsActive, user.CreatedAt, roles.ToList().AsReadOnly());
        return CreatedAtAction(nameof(GetUsers), dto);
    }

    [HttpPost("users/{id}/deactivate")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeactivateUser(string id)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user is null) return NotFound();

        // Prevent deactivating yourself
        var currentUserId = _userManager.GetUserId(User);
        if (user.Id == currentUserId)
            return BadRequest(new { message = "You cannot deactivate your own account." });

        user.IsActive = false;
        await _userManager.UpdateAsync(user);
        return NoContent();
    }

    [HttpPost("users/{id}/activate")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ActivateUser(string id)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user is null) return NotFound();

        user.IsActive = true;
        await _userManager.UpdateAsync(user);
        return NoContent();
    }

    [HttpPut("users/{id}/role")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ChangeRole(string id, ChangeUserRoleRequest request)
    {
        if (!AllowedRoles.Contains(request.Role))
            return BadRequest(new { message = $"Role must be one of: {string.Join(", ", AllowedRoles)}." });

        var user = await _userManager.FindByIdAsync(id);
        if (user is null) return NotFound();

        // Prevent removing your own admin role
        var currentUserId = _userManager.GetUserId(User);
        if (user.Id == currentUserId && request.Role != "Admin")
            return BadRequest(new { message = "You cannot change your own role." });

        var currentRoles = await _userManager.GetRolesAsync(user);
        await _userManager.RemoveFromRolesAsync(user, currentRoles);
        await _userManager.AddToRoleAsync(user, request.Role);
        return NoContent();
    }

    // ── Invitations ───────────────────────────────────────────────────────────

    [HttpGet("invitations")]
    [ProducesResponseType(typeof(IReadOnlyList<InvitationDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetInvitations(CancellationToken ct)
    {
        var invitations = await _invitations.GetActiveAsync(ct);
        var dtos = invitations.Select(i => new InvitationDto(
            i.Id, i.Token, i.Email, i.InvitedByUserId, i.CreatedAt, i.ExpiresAt, i.IsUsed)).ToList();
        return Ok(dtos);
    }

    [HttpPost("invitations")]
    [ProducesResponseType(typeof(InvitationDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateInvitation(InviteUserRequest request, CancellationToken ct)
    {
        var currentUserId = _userManager.GetUserId(User);
        if (string.IsNullOrWhiteSpace(currentUserId))
            return Unauthorized();

        var invitation = new Domain.Entities.UserInvitation(request.Email, currentUserId);
        await _invitations.AddAsync(invitation, ct);
        await _invitations.SaveChangesAsync(ct);

        var dto = new InvitationDto(invitation.Id, invitation.Token, invitation.Email,
            invitation.InvitedByUserId, invitation.CreatedAt, invitation.ExpiresAt, invitation.IsUsed);
        return CreatedAtAction(nameof(GetInvitations), dto);
    }
}
