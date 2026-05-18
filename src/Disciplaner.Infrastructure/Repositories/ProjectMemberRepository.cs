using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class ProjectMemberRepository : IProjectMemberRepository
{
    private readonly ApplicationDbContext _context;

    public ProjectMemberRepository(ApplicationDbContext context) => _context = context;

    public async Task<ProjectMember?> GetAsync(Guid projectId, string userId, CancellationToken cancellationToken = default)
        => await _context.ProjectMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.UserId == userId, cancellationToken);

    public async Task<IReadOnlyList<ProjectMember>> GetByProjectIdAsync(Guid projectId, CancellationToken cancellationToken = default)
        => await _context.ProjectMembers
            .Where(m => m.ProjectId == projectId)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(ProjectMember member, CancellationToken cancellationToken = default)
        => await _context.ProjectMembers.AddAsync(member, cancellationToken);

    public Task DeleteAsync(ProjectMember member, CancellationToken cancellationToken = default)
    {
        _context.ProjectMembers.Remove(member);
        return Task.CompletedTask;
    }
}
