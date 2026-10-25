using Disciplaner.Application.DTOs.Auth;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Identity;
using Disciplaner.Web.Server.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly JwtTokenService _tokenService;
    private readonly IUserInvitationRepository _invitations;

    public AuthController(
        UserManager<ApplicationUser> userManager,
        JwtTokenService tokenService,
        IUserInvitationRepository invitations)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _invitations = invitations;
    }

    /// <summary>
    /// Open registration — only available when no users exist (first-run).
    /// For normal multi-user operation, accounts are created by admins or via invitations.
    /// </summary>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        // Block open registration once at least one user exists
        if (_userManager.Users.Any())
            return Forbid();

        if (await _userManager.FindByEmailAsync(request.Email) is not null)
            return Conflict(new { message = "An account with this email already exists." });

        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            DisplayName = request.DisplayName,
            EmailConfirmed = true
        };

        var result = await _userManager.CreateAsync(user, request.Password);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        await _userManager.AddToRoleAsync(user, "User");

        return Ok(await BuildResponseAsync(user));
    }

    /// <summary>Authenticates and returns a JWT.</summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        var user = await _userManager.FindByEmailAsync(request.Email);

        // Unified "invalid credentials" for both unknown email and wrong password
        // to prevent username enumeration.
        if (user is null || !user.IsActive || !await _userManager.CheckPasswordAsync(user, request.Password))
            return Unauthorized(new { message = "Invalid credentials." });

        return Ok(await BuildResponseAsync(user));
    }

    /// <summary>
    /// Exchanges a valid or recently-expired JWT for a fresh one. The token may
    /// be expired for at most Jwt:RefreshWindowDays days; beyond that window the
    /// client must sign in again. Keeps idle mobile/desktop sessions alive
    /// without storing credentials on the device.
    /// </summary>
    [HttpPost("refresh")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Refresh()
    {
        var authHeader = Request.Headers.Authorization.ToString();
        if (!authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            return Unauthorized(new { message = "Missing bearer token." });

        var principal = _tokenService.ValidateTokenIgnoringLifetime(authHeader["Bearer ".Length..].Trim());
        if (principal is null)
            return Unauthorized(new { message = "Invalid token." });

        var expiredFor = DateTime.UtcNow - (JwtTokenService.GetExpiry(principal) ?? DateTime.MinValue);
        if (expiredFor > TimeSpan.FromDays(_tokenService.RefreshWindowDays))
            return Unauthorized(new { message = "Session expired, please sign in again." });

        var user = await _userManager.GetUserAsync(principal);
        if (user is null || !user.IsActive)
            return Unauthorized(new { message = "Account is inactive or missing." });

        return Ok(await BuildResponseAsync(user));
    }

    /// <summary>Returns information about an invitation token (public — no auth required).</summary>
    [HttpGet("invitation/{token}")]
    [ProducesResponseType(typeof(InvitationInfoResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetInvitationInfo(string token, CancellationToken ct)
    {
        var invitation = await _invitations.GetByTokenAsync(token, ct);
        if (invitation is null || !invitation.IsValid)
            return Ok(new InvitationInfoResponse(false, null, null));

        return Ok(new InvitationInfoResponse(true, invitation.Email, invitation.ExpiresAt));
    }

    /// <summary>Completes registration using a valid invitation token.</summary>
    [HttpPost("register-invited")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> RegisterInvited(InvitationRegisterRequest request, CancellationToken ct)
    {
        var invitation = await _invitations.GetByTokenAsync(request.Token, ct);
        if (invitation is null || !invitation.IsValid)
            return BadRequest(new { message = "The invitation link is invalid or has expired." });

        // If the invitation had a pre-filled email, enforce it
        if (invitation.Email is not null &&
            !invitation.Email.Equals(request.Email.Trim(), StringComparison.OrdinalIgnoreCase))
            return BadRequest(new { message = "This invitation was issued for a different email address." });

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

        await _userManager.AddToRoleAsync(user, "User");

        invitation.MarkUsed(user.Id);
        await _invitations.SaveChangesAsync(ct);

        return Ok(await BuildResponseAsync(user));
    }

    private async Task<AuthResponse> BuildResponseAsync(ApplicationUser user)
    {
        var roles = await _userManager.GetRolesAsync(user);
        var (token, expiresAt) = _tokenService.GenerateToken(user, roles);
        return new AuthResponse(token, user.Email!, user.DisplayName, roles.ToList().AsReadOnly(), expiresAt);
    }
}
