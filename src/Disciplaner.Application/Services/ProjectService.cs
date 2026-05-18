using Disciplaner.Application.DTOs.Member;
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
        var projects = await _uow.Projects.GetAccessibleByUserIdAsync(userId, cancellationToken);
        var summaries = new List<ProjectSummaryDto>(projects.Count);
        foreach (var p in projects)
        {
            var ticketCount = await _uow.Tickets.CountByProjectAsync(p.Id, cancellationToken);
            summaries.Add(p.ToSummaryDto(ticketCount, userId));
        }
        return summaries.AsReadOnly();
    }

    public async Task<ProjectDetailDto?> GetByIdAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken);
        if (project is null) return null;

        EnsureAccess(project, requestingUserId);

        var sprints = await _uow.Sprints.GetByProjectIdAsync(projectId, cancellationToken);
        var sprintDtos = new List<DTOs.Sprint.SprintDto>(sprints.Count);
        foreach (var s in sprints)
        {
            var count = (await _uow.Tickets.GetBySprintIdAsync(s.Id, cancellationToken)).Count;
            sprintDtos.Add(s.ToDto(count));
        }

        var members = await ResolveMembers(project.Members, cancellationToken);
        return project.ToDetailDto(sprintDtos, requestingUserId, members);
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

        return project.ToDetailDto([], ownerId, []);
    }

    public async Task<ProjectDetailDto> UpdateAsync(
        Guid projectId, string requestingUserId, UpdateProjectRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureAdmin(project, requestingUserId);

        project.Rename(request.Name);
        project.UpdateDescription(request.Description);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var members = await ResolveMembers(project.Members, cancellationToken);
        return project.ToDetailDto([], requestingUserId, members);
    }

    public async Task DeleteAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureAdmin(project, requestingUserId);

        await _uow.Projects.DeleteAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task<ProjectDetailDto> UpdateDefaultsAsync(
        Guid projectId, string requestingUserId, UpdateProjectDefaultsRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureAdmin(project, requestingUserId);

        project.UpdateDefaults(request.DefaultTicketType, request.DefaultAssigneePolicy);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var members = await ResolveMembers(project.Members, cancellationToken);
        return project.ToDetailDto([], requestingUserId, members);
    }

    public async Task<TicketStatusDto> AddStatusAsync(
        Guid projectId, string requestingUserId, CreateTicketStatusRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureSupervisor(project, requestingUserId);

        var status = project.AddStatus(request.Name, request.Category, request.Color);
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
        EnsureSupervisor(project, requestingUserId);

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
        EnsureSupervisor(project, requestingUserId);

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
        await _uow.SaveChangesAsync(cancellationToken);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static void EnsureAccess(Project project, string userId)
    {
        if (!project.HasAccess(userId))
            throw new ForbiddenException($"User '{userId}' does not have access to project '{project.Id}'.");
    }

    private static void EnsureSupervisor(Project project, string userId)
    {
        if (!project.CanManage(userId))
            throw new ForbiddenException($"User '{userId}' requires Supervisor role on project '{project.Id}'.");
    }

    private static void EnsureAdmin(Project project, string userId)
    {
        if (!project.CanAdminister(userId))
            throw new ForbiddenException($"User '{userId}' requires Admin role on project '{project.Id}'.");
    }

    private async Task<IReadOnlyList<MemberDto>> ResolveMembers(
        IReadOnlyCollection<ProjectMember> members, CancellationToken cancellationToken)
    {
        var result = new List<MemberDto>(members.Count);
        foreach (var m in members)
        {
            var user = await _uow.Users.GetByIdAsync(m.UserId, cancellationToken);
            if (user is null) continue;
            result.Add(new MemberDto(m.UserId, user.DisplayName, user.Email, m.Role, m.JoinedAt));
        }
        return result.AsReadOnly();
    }
}
