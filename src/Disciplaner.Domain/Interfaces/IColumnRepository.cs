using Disciplaner.Domain.Entities;

namespace Disciplaner.Domain.Interfaces;

public interface IColumnRepository
{
    Task<Column?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Column?> GetByIdWithCardsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Column>> GetByBoardIdAsync(Guid boardId, CancellationToken cancellationToken = default);
    Task AddAsync(Column column, CancellationToken cancellationToken = default);
    Task UpdateAsync(Column column, CancellationToken cancellationToken = default);
    Task DeleteAsync(Column column, CancellationToken cancellationToken = default);
}
