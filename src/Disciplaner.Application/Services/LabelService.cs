using Disciplaner.Application.DTOs.Board;
using Disciplaner.Application.DTOs.Label;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Mappings;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class LabelService : ILabelService
{
    private readonly IUnitOfWork _uow;

    public LabelService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<LabelDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var labels = await _uow.Labels.GetAllAsync(cancellationToken);
        return labels.Select(l => l.ToDto()).ToList().AsReadOnly();
    }

    public async Task<LabelDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var label = await _uow.Labels.GetByIdAsync(id, cancellationToken);
        return label?.ToDto();
    }

    public async Task<LabelItemsDto?> GetItemsByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var label = await _uow.Labels.GetByIdWithItemsAsync(id, cancellationToken);
        if (label is null) return null;

        var tickets = label.Tickets.Select(t => new TicketSummaryDto(
            t.Id,
            t.ProjectId,
            t.Project?.Key ?? string.Empty,
            $"{t.Project?.Key ?? "?"}-{t.TicketNumber}",
            t.Title,
            t.Type.ToString(),
            t.Priority.ToString(),
            t.Status?.Name ?? string.Empty,
            t.Status?.Color ?? "#888"
        )).ToList().AsReadOnly();

        var boards = label.Boards.Select(b => new BoardSummaryDto(
            b.Id,
            b.Name,
            b.Description,
            b.Columns.Count,
            b.CreatedAt,
            b.Labels.Select(l => l.ToDto()).ToList().AsReadOnly()
        )).ToList().AsReadOnly();

        return new LabelItemsDto(label.ToDto(), tickets, boards);
    }

    public async Task<LabelDto> CreateAsync(CreateLabelRequest request, CancellationToken cancellationToken = default)
    {
        var label = new Label(request.Name, request.Color);
        await _uow.Labels.AddAsync(label, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return label.ToDto();
    }

    public async Task<LabelDto> UpdateAsync(Guid id, UpdateLabelRequest request, CancellationToken cancellationToken = default)
    {
        var label = await _uow.Labels.GetByIdAsync(id, cancellationToken)
            ?? throw new NotFoundException(nameof(Label), id);
        label.Update(request.Name, request.Color);
        await _uow.Labels.UpdateAsync(label, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return label.ToDto();
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var label = await _uow.Labels.GetByIdAsync(id, cancellationToken)
            ?? throw new NotFoundException(nameof(Label), id);
        await _uow.Labels.DeleteAsync(label, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task AttachToTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default)
    {
        await _uow.Labels.AttachToTicketAsync(labelId, ticketId, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task DetachFromTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default)
    {
        await _uow.Labels.DetachFromTicketAsync(labelId, ticketId, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task AttachToBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default)
    {
        await _uow.Labels.AttachToBoardAsync(labelId, boardId, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    public async Task DetachFromBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default)
    {
        await _uow.Labels.DetachFromBoardAsync(labelId, boardId, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }
}
