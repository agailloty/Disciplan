using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
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

    public async Task<IReadOnlyList<Sprint>> GetActiveForUserAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.Sprints
            .Where(s => s.Status == SprintStatus.Active
                && _context.Projects
                    .Where(p => p.Id == s.ProjectId)
                    .Any(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId)))
            .OrderBy(s => s.StartDate)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Sprint>> GetWithDatesForUserAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.Sprints
            .Include(s => s.Project)
            .Where(s => s.StartDate != null && s.EndDate != null
                && _context.Projects
                    .Where(p => p.Id == s.ProjectId)
                    .Any(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId)))
            .OrderBy(s => s.StartDate)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Sprint sprint, CancellationToken cancellationToken = default)
        => await _context.Sprints.AddAsync(sprint, cancellationToken);

    public Task UpdateAsync(Sprint sprint, CancellationToken cancellationToken = default)
    {
        _context.Sprints.Update(sprint);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Sprint sprint, CancellationToken cancellationToken = default)
    {
        _context.Sprints.Remove(sprint);
        return Task.CompletedTask;
    }
}
