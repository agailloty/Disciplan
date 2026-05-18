using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IUserInvitationRepository
{
    Task<UserInvitation?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserInvitation>> GetActiveAsync(CancellationToken cancellationToken = default);
    Task AddAsync(UserInvitation invitation, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
