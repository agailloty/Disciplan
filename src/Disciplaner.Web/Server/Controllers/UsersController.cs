using Disciplaner.Application;
using Disciplaner.Application.DTOs.User;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Identity;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Disciplaner.Web.Server.Controllers;

[ApiController]
[Authorize]
public sealed class UsersController : ControllerBase
{
    private readonly IUserRepository _users;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IFileStorageService _fileStorage;
    private readonly FileStorageOptions _fileStorageOptions;

    public UsersController(
        IUserRepository users,
        UserManager<ApplicationUser> userManager,
        IFileStorageService fileStorage,
        IOptions<FileStorageOptions> fileStorageOptions)
    {
        _users = users;
        _userManager = userManager;
        _fileStorage = fileStorage;
        _fileStorageOptions = fileStorageOptions.Value;
    }

    [HttpGet("api/users")]
    [ProducesResponseType(typeof(IReadOnlyList<UserSummaryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var users = await _users.GetAllAsync(ct);
        var dtos = users
            .Where(u => u.IsActive)
            .Select(u => new UserSummaryDto(u.Id, u.DisplayName, u.Email, u.ProfilePictureUrl))
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

    [HttpPut("api/users/me/profile-picture")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateProfilePicture(IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
            return BadRequest(new { error = "No file provided." });

        if (!_fileStorageOptions.AllowedProfilePictureContentTypes
                .Contains(file.ContentType, StringComparer.OrdinalIgnoreCase))
            return BadRequest(new { error = "Only image files (JPEG, PNG, GIF, WebP) are accepted." });

        if (file.Length > _fileStorageOptions.MaxProfilePictureSizeBytes)
            return BadRequest(new { error = $"Profile picture must be under {_fileStorageOptions.MaxProfilePictureSizeBytes / 1024 / 1024} MB." });

        var user = await _userManager.GetUserAsync(User);
        if (user is null) return Unauthorized();

        // Delete old profile picture if one exists
        if (!string.IsNullOrWhiteSpace(user.ProfilePictureUrl))
            await _fileStorage.DeleteAsync(user.ProfilePictureUrl, ct);

        var storagePath = await _fileStorage.SaveAsync(file.OpenReadStream(), file.FileName, "profiles", ct);
        user.ProfilePictureUrl = storagePath;

        var result = await _userManager.UpdateAsync(user);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        return Ok(new { profilePictureUrl = storagePath });
    }

    [HttpDelete("api/users/me/profile-picture")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> DeleteProfilePicture(CancellationToken ct)
    {
        var user = await _userManager.GetUserAsync(User);
        if (user is null) return Unauthorized();

        if (!string.IsNullOrWhiteSpace(user.ProfilePictureUrl))
        {
            await _fileStorage.DeleteAsync(user.ProfilePictureUrl, ct);
            user.ProfilePictureUrl = null;
            await _userManager.UpdateAsync(user);
        }

        return NoContent();
    }

    [HttpGet("api/attachments/profile/{**storagePath}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult GetProfilePicture(string storagePath)
    {
        // Only allow paths under "profiles/" to prevent path traversal
        if (!storagePath.StartsWith("profiles/", StringComparison.OrdinalIgnoreCase))
            return NotFound();

        var absolutePath = _fileStorage.GetAbsolutePath(storagePath);
        if (!System.IO.File.Exists(absolutePath))
            return NotFound();

        var ext = Path.GetExtension(absolutePath).ToLowerInvariant();
        var contentType = ext switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png"            => "image/png",
            ".gif"            => "image/gif",
            ".webp"           => "image/webp",
            _                 => "application/octet-stream"
        };

        return PhysicalFile(absolutePath, contentType, enableRangeProcessing: false);
    }
}
