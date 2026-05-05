using Disciplaner.Application.DTOs.Label;

namespace Disciplaner.Application.Interfaces;

public interface ILabelService
{
    Task<IReadOnlyList<LabelDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LabelDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<LabelItemsDto?> GetItemsByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<LabelDto> CreateAsync(CreateLabelRequest request, CancellationToken cancellationToken = default);
    Task<LabelDto> UpdateAsync(Guid id, UpdateLabelRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task AttachToTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default);
    Task DetachFromTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default);
    Task AttachToBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default);
    Task DetachFromBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default);
}
