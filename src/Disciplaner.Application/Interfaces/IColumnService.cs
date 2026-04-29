using Disciplaner.Application.DTOs.Column;

namespace Disciplaner.Application.Interfaces;

public interface IColumnService
{
    /// <summary>Returns all columns for a board, ordered by their position.</summary>
    Task<IReadOnlyList<ColumnDto>> GetByBoardAsync(Guid boardId, string requestingUserId, CancellationToken cancellationToken = default);

    /// <summary>Returns a single column with its cards.</summary>
    Task<ColumnDto?> GetByIdAsync(Guid columnId, string requestingUserId, CancellationToken cancellationToken = default);

    /// <summary>Adds a new column at the end of the board.</summary>
    Task<ColumnDto> CreateAsync(Guid boardId, string requestingUserId, CreateColumnRequest request, CancellationToken cancellationToken = default);

    /// <summary>Renames an existing column.</summary>
    Task<ColumnDto> UpdateAsync(Guid columnId, string requestingUserId, UpdateColumnRequest request, CancellationToken cancellationToken = default);

    /// <summary>Moves a column to a new position within its board.</summary>
    Task ReorderAsync(Guid columnId, string requestingUserId, MoveColumnRequest request, CancellationToken cancellationToken = default);

    /// <summary>Deletes a column and all its cards.</summary>
    Task DeleteAsync(Guid columnId, string requestingUserId, CancellationToken cancellationToken = default);
}
