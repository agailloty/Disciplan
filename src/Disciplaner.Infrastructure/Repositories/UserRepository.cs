using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class UserRepository : IUserRepository
{
    private readonly UserManager<ApplicationUser> _userManager;

    public UserRepository(UserManager<ApplicationUser> userManager)
        => _userManager = userManager;

    public async Task<User?> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        var app = await _userManager.FindByIdAsync(id);
        return app is null ? null : Map(app);
    }

    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var app = await _userManager.FindByEmailAsync(email);
        return app is null ? null : Map(app);
    }

    public async Task<IReadOnlyList<User>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var users = _userManager.Users.ToList();
        return users.Select(Map).ToList().AsReadOnly();
    }

    public async Task<bool> ExistsAsync(string id, CancellationToken cancellationToken = default)
        => await _userManager.FindByIdAsync(id) is not null;

    private static User Map(ApplicationUser app)
        => new(app.Id, app.UserName ?? app.Email ?? app.Id, app.Email ?? string.Empty, app.DisplayName);
}
