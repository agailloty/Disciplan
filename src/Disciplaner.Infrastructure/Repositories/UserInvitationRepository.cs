using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class UserInvitationRepository : IUserInvitationRepository
{
    private readonly ApplicationDbContext _db;

    public UserInvitationRepository(ApplicationDbContext db) => _db = db;

    public Task<UserInvitation?> GetByTokenAsync(string token, CancellationToken cancellationToken = default)
        => _db.UserInvitations.FirstOrDefaultAsync(i => i.Token == token, cancellationToken);

    public async Task<IReadOnlyList<UserInvitation>> GetActiveAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var list = await _db.UserInvitations
            .Where(i => !i.IsUsed && i.ExpiresAt > now)
            .OrderByDescending(i => i.CreatedAt)
            .ToListAsync(cancellationToken);
        return list.AsReadOnly();
    }

    public async Task AddAsync(UserInvitation invitation, CancellationToken cancellationToken = default)
        => await _db.UserInvitations.AddAsync(invitation, cancellationToken);

    public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        => _db.SaveChangesAsync(cancellationToken);
}
