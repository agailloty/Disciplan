using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Disciplaner.Infrastructure.Identity;

public static class IdentitySeeder
{
    /// <summary>
    /// Seeds roles and, optionally, the initial admin account from configuration.
    /// If no AdminSeed credentials are provided and no users exist yet, the application
    /// enters "first-run" mode: the /api/setup endpoint handles admin creation instead.
    /// </summary>
    public static async Task SeedAsync(IServiceProvider services, IConfiguration configuration)
    {
        await using var scope = services.CreateAsyncScope();
        var sp = scope.ServiceProvider;

        var roleManager = sp.GetRequiredService<RoleManager<IdentityRole>>();
        var userManager = sp.GetRequiredService<UserManager<ApplicationUser>>();

        // Always ensure roles exist
        foreach (var role in new[] { "Admin", "User" })
        {
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new IdentityRole(role));
        }

        var adminEmail    = configuration["AdminSeed:Email"];
        var adminPassword = configuration["AdminSeed:Password"];

        // If config is absent/placeholder, skip seeding — first-run setup endpoint handles this.
        bool hasEmailConfig    = !string.IsNullOrWhiteSpace(adminEmail)    && !adminEmail.Contains("REPLACE");
        bool hasPasswordConfig = !string.IsNullOrWhiteSpace(adminPassword) && !adminPassword.Contains("REPLACE");

        if (!hasEmailConfig || !hasPasswordConfig)
            return; // First-run mode: no seed, /api/setup creates the admin

        if (await userManager.FindByEmailAsync(adminEmail!) is not null)
            return; // Already seeded

        var admin = new ApplicationUser
        {
            UserName = adminEmail,
            Email = adminEmail,
            DisplayName = "Administrator",
            EmailConfirmed = true
        };

        var result = await userManager.CreateAsync(admin, adminPassword!);
        if (!result.Succeeded)
            throw new InvalidOperationException(
                $"Admin seed failed: {string.Join(", ", result.Errors.Select(e => e.Description))}");

        await userManager.AddToRoleAsync(admin, "Admin");
    }

    /// <summary>Returns true when no users exist and the app needs first-run setup.</summary>
    public static async Task<bool> IsSetupRequiredAsync(IServiceProvider services)
    {
        await using var scope = services.CreateAsyncScope();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        return !userManager.Users.Any();
    }
}
