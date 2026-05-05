using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.TicketStatus;

namespace Disciplaner.Application.Interfaces;

public interface IProjectService
{
    Task<IReadOnlyList<ProjectSummaryDto>> GetAllByUserAsync(string userId, CancellationToken cancellationToken = default);
    Task<ProjectDetailDto?> GetByIdAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<ProjectDetailDto> CreateAsync(string ownerId, CreateProjectRequest request, CancellationToken cancellationToken = default);
    Task<ProjectDetailDto> UpdateAsync(Guid projectId, string requestingUserId, UpdateProjectRequest request, CancellationToken cancellationToken = default);
    Task<ProjectDetailDto> UpdateDefaultsAsync(Guid projectId, string requestingUserId, UpdateProjectDefaultsRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);

    Task<TicketStatusDto> AddStatusAsync(Guid projectId, string requestingUserId, CreateTicketStatusRequest request, CancellationToken cancellationToken = default);
    Task<TicketStatusDto> UpdateStatusAsync(Guid projectId, Guid statusId, string requestingUserId, UpdateTicketStatusRequest request, CancellationToken cancellationToken = default);
    Task DeleteStatusAsync(Guid projectId, Guid statusId, string requestingUserId, CancellationToken cancellationToken = default);
}
