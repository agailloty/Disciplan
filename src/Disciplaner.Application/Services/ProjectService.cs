using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Exceptions;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class ProjectService : IProjectService
{
    private readonly IUnitOfWork _uow;

    public ProjectService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<ProjectSummaryDto>> GetAllByUserAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var projects = await _uow.Projects.GetByOwnerIdAsync(userId, cancellationToken);
        var summaries = new List<ProjectSummaryDto>(projects.Count);
        foreach (var p in projects)
        {
            var ticketCount = await _uow.Tickets.CountByProjectAsync(p.Id, cancellationToken);
            summaries.Add(p.ToSummaryDto(ticketCount));
        }
        return summaries.AsReadOnly();
    }

    public async Task<ProjectDetailDto?> GetByIdAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken);
        if (project is null) return null;
        EnsureOwner(project, requestingUserId);

        var sprints = await _uow.Sprints.GetByProjectIdAsync(projectId, cancellationToken);
        var sprintDtos = new List<DTOs.Sprint.SprintDto>(sprints.Count);
        foreach (var s in sprints)
        {
            var count = (await _uow.Tickets.GetBySprintIdAsync(s.Id, cancellationToken)).Count;
            sprintDtos.Add(s.ToDto(count));
        }

        return project.ToDetailDto(sprintDtos);
    }

    public async Task<ProjectDetailDto> CreateAsync(
        string ownerId, CreateProjectRequest request, CancellationToken cancellationToken = default)
    {
        var owner = await _uow.Users.GetByIdAsync(ownerId, cancellationToken)
            ?? throw new NotFoundException("User", ownerId);

        if (await _uow.Projects.KeyExistsAsync(request.Key.ToUpperInvariant(), cancellationToken))
            throw new InvalidOperationException($"Project key '{request.Key.ToUpperInvariant()}' already exists.");

        var project = new Project(request.Name, request.Description, request.Key, owner);
        await _uow.Projects.AddAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return project.ToDetailDto([]);
    }

    public async Task<ProjectDetailDto> UpdateAsync(
        Guid projectId, string requestingUserId, UpdateProjectRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        project.Rename(request.Name);
        project.UpdateDescription(request.Description);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return project.ToDetailDto([]);
    }

    public async Task DeleteAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        await _uow.Projects.DeleteAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task<ProjectDetailDto> UpdateDefaultsAsync(
        Guid projectId, string requestingUserId, UpdateProjectDefaultsRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        project.UpdateDefaults(request.DefaultTicketType, request.DefaultAssigneePolicy);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return project.ToDetailDto([]);
    }

    public async Task<TicketStatusDto> AddStatusAsync(
        Guid projectId, string requestingUserId, CreateTicketStatusRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        var status = project.AddStatus(request.Name, request.Category, request.Color);
        // Explicitly mark the new TicketStatus as Added so EF generates INSERT.
        // Without this, EF sees a non-default Guid key with ValueGeneratedOnAdd
        // and generates UPDATE instead of INSERT, causing DbUpdateConcurrencyException.
        await _uow.Projects.AddTicketStatusAsync(status, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return status.ToDto();
    }

    public async Task<TicketStatusDto> UpdateStatusAsync(
        Guid projectId, Guid statusId, string requestingUserId, UpdateTicketStatusRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        project.UpdateStatus(statusId, request.Name, request.Category, request.Color);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return project.Statuses.First(s => s.Id == statusId).ToDto();
    }

    public async Task DeleteStatusAsync(
        Guid projectId, Guid statusId, string requestingUserId,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        // Guard: status must not be in use
        var backlog = await _uow.Tickets.GetBacklogAsync(projectId, cancellationToken);
        var inUse = backlog.Any(t => t.StatusId == statusId);
        if (!inUse)
        {
            var sprints = await _uow.Sprints.GetByProjectIdAsync(projectId, cancellationToken);
            foreach (var sprint in sprints)
            {
                var sprintTickets = await _uow.Tickets.GetBySprintIdAsync(sprint.Id, cancellationToken);
                if (sprintTickets.Any(t => t.StatusId == statusId)) { inUse = true; break; }
            }
        }
        if (inUse) throw ProjectDomainException.StatusInUse();

        project.RemoveStatus(statusId);
        // Entities are already tracked; Update() is not needed and would interfere.
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private static void EnsureOwner(Project project, string userId)
    {
        if (project.OwnerId != userId)
            throw new UnauthorizedAccessException("Access denied.");
    }
}
