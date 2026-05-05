using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface ILabelRepository
{
    Task<IReadOnlyList<Label>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<Label?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Label?> GetByIdWithItemsAsync(Guid id, CancellationToken cancellationToken = default);
    Task AddAsync(Label label, CancellationToken cancellationToken = default);
    Task UpdateAsync(Label label, CancellationToken cancellationToken = default);
    Task DeleteAsync(Label label, CancellationToken cancellationToken = default);
    Task AttachToTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default);
    Task DetachFromTicketAsync(Guid labelId, Guid ticketId, CancellationToken cancellationToken = default);
    Task AttachToBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default);
    Task DetachFromBoardAsync(Guid labelId, Guid boardId, CancellationToken cancellationToken = default);
}
