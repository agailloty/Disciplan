using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class ProjectRepository : IProjectRepository
{
    private readonly ApplicationDbContext _context;

    public ProjectRepository(ApplicationDbContext context) => _context = context;

    public async Task<Project?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Projects.FindAsync([id], cancellationToken);

    public async Task<Project?> GetByIdWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Projects
            .Include(p => p.Statuses.OrderBy(s => s.Order))
            .Include(p => p.Sprints.OrderBy(s => s.CreatedAt))
            .Include(p => p.Members)
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);

    public async Task<Project?> GetByIdWithMembersAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Projects
            .Include(p => p.Members)
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);

    public async Task<IReadOnlyList<Project>> GetByOwnerIdAsync(string ownerId, CancellationToken cancellationToken = default)
        => await _context.Projects
            .Include(p => p.Sprints)
            .Include(p => p.Members)
            .Where(p => p.OwnerId == ownerId)
            .OrderBy(p => p.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Project>> GetAccessibleByUserIdAsync(string userId, CancellationToken cancellationToken = default)
        => await _context.Projects
            .Include(p => p.Sprints)
            .Include(p => p.Members)
            .Where(p => p.OwnerId == userId || p.Members.Any(m => m.UserId == userId))
            .OrderBy(p => p.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<bool> KeyExistsAsync(string key, CancellationToken cancellationToken = default)
        => await _context.Projects.AnyAsync(p => p.Key == key, cancellationToken);

    public async Task AddAsync(Project project, CancellationToken cancellationToken = default)
        => await _context.Projects.AddAsync(project, cancellationToken);

    public Task UpdateAsync(Project project, CancellationToken cancellationToken = default)
    {
        _context.Projects.Update(project);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Project project, CancellationToken cancellationToken = default)
    {
        _context.Projects.Remove(project);
        return Task.CompletedTask;
    }

    public async Task AddTicketStatusAsync(TicketStatus status, CancellationToken cancellationToken = default)
        => await _context.TicketStatuses.AddAsync(status, cancellationToken);
}
