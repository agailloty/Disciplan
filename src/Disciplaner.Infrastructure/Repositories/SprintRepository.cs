using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class SprintRepository : ISprintRepository
{
    private readonly ApplicationDbContext _context;

    public SprintRepository(ApplicationDbContext context) => _context = context;

    public async Task<Sprint?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Sprints.FindAsync([id], cancellationToken);

    public async Task<IReadOnlyList<Sprint>> GetByProjectIdAsync(Guid projectId, CancellationToken cancellationToken = default)
        => await _context.Sprints
            .Where(s => s.ProjectId == projectId)
            .OrderBy(s => s.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task UpdateAsync(Sprint sprint, CancellationToken cancellationToken = default)
    {
        _context.Sprints.Update(sprint);
        return Task.CompletedTask;
    }
}
