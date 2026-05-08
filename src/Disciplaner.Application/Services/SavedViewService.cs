using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.DTOs.SavedView;
using Disciplaner.Application.DTOs.Ticket;
using Disciplaner.Application.DTOs.TicketStatus;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class SavedViewService : ISavedViewService
{
    private readonly IUnitOfWork _uow;

    public SavedViewService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<SavedViewDto>> GetByUserAsync(
        string userId, CancellationToken cancellationToken = default)
    {
        var views = await _uow.SavedViews.GetByUserAsync(userId, cancellationToken);
        return views.Select(ToDto).ToList().AsReadOnly();
    }

    public async Task<SavedViewDto> CreateAsync(
        string userId, CreateSavedViewRequest request, CancellationToken cancellationToken = default)
    {
        var view = new SavedView(request.Name, request.Description, userId);
        view.Update(
            request.Name,
            request.Description,
            request.IsVisibleOnHome,
            request.DisplayOrder,
            request.ProjectId,
            request.StatusId,
            request.SprintId,
            request.Type,
            request.Priority,
            request.StatusCategories,
            request.OnlyAssignedToMe,
            request.OnlyReportedByMe);

        await _uow.SavedViews.AddAsync(view, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return ToDto(view);
    }

    public async Task<SavedViewDto> UpdateAsync(
        Guid viewId, string userId, UpdateSavedViewRequest request, CancellationToken cancellationToken = default)
    {
        var view = await _uow.SavedViews.GetByIdAsync(viewId, cancellationToken)
            ?? throw new NotFoundException(nameof(SavedView), viewId);

        EnsureOwner(view, userId);

        view.Update(
            request.Name,
            request.Description,
            request.IsVisibleOnHome,
            request.DisplayOrder,
            request.ProjectId,
            request.StatusId,
            request.SprintId,
            request.Type,
            request.Priority,
            request.StatusCategories,
            request.OnlyAssignedToMe,
            request.OnlyReportedByMe);

        await _uow.SavedViews.UpdateAsync(view, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return ToDto(view);
    }

    public async Task DeleteAsync(
        Guid viewId, string userId, CancellationToken cancellationToken = default)
    {
        var view = await _uow.SavedViews.GetByIdAsync(viewId, cancellationToken)
            ?? throw new NotFoundException(nameof(SavedView), viewId);

        EnsureOwner(view, userId);

        await _uow.SavedViews.DeleteAsync(view, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<TicketDto>> ExecuteAsync(
        Guid viewId, string userId, CancellationToken cancellationToken = default)
    {
        var view = await _uow.SavedViews.GetByIdAsync(viewId, cancellationToken)
            ?? throw new NotFoundException(nameof(SavedView), viewId);

        EnsureOwner(view, userId);

        var assigneeId = view.OnlyAssignedToMe ? userId : null;
        var reporterId = view.OnlyReportedByMe ? userId : null;

        var tickets = await _uow.Tickets.GetFilteredAsync(
            view.ProjectId,
            view.StatusId,
            view.SprintId,
            view.Type,
            view.Priority,
            view.StatusCategories.Count > 0 ? view.StatusCategories : null,
            assigneeId,
            reporterId,
            cancellationToken);

        return await ToDtoListAsync(tickets, cancellationToken);
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private static void EnsureOwner(SavedView view, string userId)
    {
        if (view.UserId != userId) throw new UnauthorizedAccessException("Access denied.");
    }

    private async Task<IReadOnlyList<TicketDto>> ToDtoListAsync(IReadOnlyList<Ticket> tickets, CancellationToken ct)
    {
        var userIds = tickets
            .SelectMany(t => new[] { t.ReporterId, t.AssigneeId })
            .Where(id => id is not null)
            .Select(id => id!)
            .Distinct();

        var names = new Dictionary<string, string>();
        foreach (var id in userIds)
        {
            var u = await _uow.Users.GetByIdAsync(id, ct);
            if (u is not null) names[id] = u.DisplayName;
        }

        return tickets
            .Select(t => ToTicketDto(t,
                names.GetValueOrDefault(t.ReporterId, t.ReporterId),
                t.AssigneeId is not null ? names.GetValueOrDefault(t.AssigneeId, t.AssigneeId) : null))
            .ToList()
            .AsReadOnly();
    }

    private static TicketDto ToTicketDto(Ticket t, string reporterName, string? assigneeName) => new(
        t.Id,
        t.ProjectId,
        t.Project?.Key ?? string.Empty,
        t.TicketNumber,
        $"{t.Project?.Key ?? "?"}-{t.TicketNumber}",
        t.Title,
        t.Description,
        t.Type,
        t.Priority,
        t.StoryPoints,
        t.DueDate,
        t.Status is not null
            ? new TicketStatusDto(t.Status.Id, t.Status.ProjectId, t.Status.Name, t.Status.Color, t.Status.Order, t.Status.Category)
            : null!,
        t.SprintId,
        t.Sprint?.Name,
        t.ParentTicketId,
        t.ParentTicket is not null ? $"{t.Project?.Key ?? "?"}-{t.ParentTicket.TicketNumber}" : null,
        t.ReporterId,
        reporterName,
        t.AssigneeId,
        assigneeName,
        t.CreatedAt,
        t.UpdatedAt,
        t.Labels.Select(l => new LabelDto(l.Id, l.Name, l.Color, l.CreatedAt)).ToList().AsReadOnly()
    );

    private static SavedViewDto ToDto(SavedView v) => new(
        v.Id,
        v.Name,
        v.Description,
        v.IsVisibleOnHome,
        v.DisplayOrder,
        v.ProjectId,
        v.StatusId,
        v.SprintId,
        v.Type,
        v.Priority,
        v.StatusCategories.AsReadOnly(),
        v.OnlyAssignedToMe,
        v.OnlyReportedByMe,
        v.CreatedAt,
        v.UpdatedAt);
}
