using Disciplaner.Application.DTOs.Activity;

namespace Disciplaner.Application.Interfaces;

public interface IActivityService
{
    Task<IReadOnlyList<ActivityItemDto>> GetRecentActivityAsync(
        string userId, int limit = 20, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<TicketActivityGroupDto>> GetRecentGroupedAsync(
        string userId, int limit = 20, CancellationToken cancellationToken = default);
}
