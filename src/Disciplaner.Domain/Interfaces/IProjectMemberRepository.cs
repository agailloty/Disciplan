using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IProjectMemberRepository
{
    Task<ProjectMember?> GetAsync(Guid projectId, string userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ProjectMember>> GetByProjectIdAsync(Guid projectId, CancellationToken cancellationToken = default);
    Task AddAsync(ProjectMember member, CancellationToken cancellationToken = default);
    Task DeleteAsync(ProjectMember member, CancellationToken cancellationToken = default);
}
