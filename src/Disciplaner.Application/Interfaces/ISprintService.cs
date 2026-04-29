using Disciplaner.Application.DTOs.Sprint;

namespace Disciplaner.Application.Interfaces;

public interface ISprintService
{
    Task<IReadOnlyList<SprintDto>> GetByProjectAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<SprintDto> CreateAsync(Guid projectId, string requestingUserId, CreateSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> UpdateAsync(Guid sprintId, string requestingUserId, UpdateSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> StartAsync(Guid sprintId, string requestingUserId, StartSprintRequest request, CancellationToken cancellationToken = default);
    Task<SprintDto> CloseAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
}
