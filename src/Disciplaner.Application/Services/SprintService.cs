using Disciplaner.Application.DTOs.Sprint;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class SprintService : ISprintService
{
    private readonly IUnitOfWork _uow;

    public SprintService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<SprintDto>> GetByProjectAsync(
        Guid projectId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureProjectAccessAsync(projectId, requestingUserId, cancellationToken);
        var sprints = await _uow.Sprints.GetByProjectIdAsync(projectId, cancellationToken);
        var result = new List<SprintDto>(sprints.Count);
        foreach (var s in sprints)
        {
            var count = (await _uow.Tickets.GetBySprintIdAsync(s.Id, cancellationToken)).Count;
            result.Add(s.ToDto(count));
        }
        return result.AsReadOnly();
    }

    public async Task<SprintDto> CreateAsync(
        Guid projectId, string requestingUserId, CreateSprintRequest request,
        CancellationToken cancellationToken = default)
    {
        var project = await _uow.Projects.GetByIdWithDetailsAsync(projectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, requestingUserId);

        var sprint = project.AddSprint(request.Name, request.Goal);
        await _uow.Sprints.AddAsync(sprint, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return sprint.ToDto(0);
    }

    public async Task<SprintDto> UpdateAsync(
        Guid sprintId, string requestingUserId, UpdateSprintRequest request,
        CancellationToken cancellationToken = default)
    {
        var sprint = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)
            ?? throw new NotFoundException(nameof(Sprint), sprintId);
        await EnsureProjectAccessAsync(sprint.ProjectId, requestingUserId, cancellationToken);

        sprint.Update(request.Name, request.Goal, request.StartDate, request.EndDate);
        await _uow.Sprints.UpdateAsync(sprint, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var count = (await _uow.Tickets.GetBySprintIdAsync(sprintId, cancellationToken)).Count;
        return sprint.ToDto(count);
    }

    public async Task<SprintDto> StartAsync(
        Guid sprintId, string requestingUserId, StartSprintRequest request,
        CancellationToken cancellationToken = default)
    {
        var sprint = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)
            ?? throw new NotFoundException(nameof(Sprint), sprintId);

        var project = await _uow.Projects.GetByIdWithDetailsAsync(sprint.ProjectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), sprint.ProjectId);
        EnsureOwner(project, requestingUserId);

        project.StartSprint(sprintId, request.StartDate, request.EndDate);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var updated = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)!;
        var count = (await _uow.Tickets.GetBySprintIdAsync(sprintId, cancellationToken)).Count;
        return updated!.ToDto(count);
    }

    public async Task<SprintDto> CloseAsync(
        Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var sprint = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)
            ?? throw new NotFoundException(nameof(Sprint), sprintId);

        var project = await _uow.Projects.GetByIdWithDetailsAsync(sprint.ProjectId, cancellationToken)
            ?? throw new NotFoundException(nameof(Project), sprint.ProjectId);
        EnsureOwner(project, requestingUserId);

        project.CloseSprint(sprintId);
        await _uow.Projects.UpdateAsync(project, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        var updated = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)!;
        var count = (await _uow.Tickets.GetBySprintIdAsync(sprintId, cancellationToken)).Count;
        return updated!.ToDto(count);
    }

    public async Task DeleteAsync(
        Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var sprint = await _uow.Sprints.GetByIdAsync(sprintId, cancellationToken)
            ?? throw new NotFoundException(nameof(Sprint), sprintId);
        await EnsureProjectAccessAsync(sprint.ProjectId, requestingUserId, cancellationToken);

        // Move sprint tickets back to backlog
        var tickets = await _uow.Tickets.GetBySprintIdAsync(sprintId, cancellationToken);
        foreach (var ticket in tickets)
        {
            ticket.MoveToSprint((Guid?)null);
            await _uow.Tickets.UpdateAsync(ticket, cancellationToken);
        }

        await _uow.Sprints.DeleteAsync(sprint, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    private async Task EnsureProjectAccessAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        EnsureOwner(project, userId);
    }

    private static void EnsureOwner(Project project, string userId)
    {
        if (project.OwnerId != userId) throw new UnauthorizedAccessException("Access denied.");
    }
}
