using Microsoft.AspNetCore.Identity;

namespace Disciplaner.Infrastructure.Identity;

/// <summary>
/// ASP.NET Core Identity user. Lives in Infrastructure only.
/// The Domain's User entity is the business object; this class handles authentication concerns.
/// </summary>
public sealed class ApplicationUser : IdentityUser
{
    public string DisplayName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
    public bool IsActive { get; set; } = true;
    public string? ProfilePictureUrl { get; set; }
}
