using Disciplaner.Application.DTOs.Sprint;

namespace Disciplaner.Application.Interfaces;

public interface ISprintService
{
    Task<IReadOnlyList<SprintDto>> GetActiveForUserAsync(string userId, CancellationToken cancellationToken = default);
    /// <summary>Returns all sprints (any status) accessible to the user that have both StartDate and EndDate set.</summary>
    Task<IReadOnlyList<SprintDto>> GetWithDatesForUserAsync(string userId, CancellationToken cancellationToken = default);
    Task<SprintDetailDto?> GetByIdAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SprintDto>> GetByProjectAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<SprintDto> CreateAsync(Guid projectId, string requestingUserId, CreateSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> UpdateAsync(Guid sprintId, string requestingUserId, UpdateSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> StartAsync(Guid sprintId, string requestingUserId, StartSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> CloseAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
}
