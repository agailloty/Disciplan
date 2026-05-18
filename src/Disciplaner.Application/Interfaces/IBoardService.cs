using Disciplaner.Application.DTOs.Board;

namespace Disciplaner.Application.Interfaces;

public interface IBoardService
{
    /// <summary>Returns all boards owned by or shared with the given user.</summary>
    Task<IReadOnlyList<BoardSummaryDto>> GetAllByUserAsync(string userId, CancellationToken cancellationToken = default);

    /// <summary>Returns a board with its full column and card tree. Access requires at least Guest role.</summary>
    Task<BoardDetailDto?> GetByIdAsync(Guid boardId, string requestingUserId, CancellationToken cancellationToken = default);

    /// <summary>Creates a new board owned by the given user.</summary>
    Task<BoardDetailDto> CreateAsync(string ownerId, CreateBoardRequest request, CancellationToken cancellationToken = default);

    /// <summary>Renames or updates the description of an existing board. Requires Admin role.</summary>
    Task<BoardDetailDto> UpdateAsync(Guid boardId, string requestingUserId, UpdateBoardRequest request, CancellationToken cancellationToken = default);

    /// <summary>Permanently deletes a board and all its columns and cards. Requires Admin role.</summary>
    Task DeleteAsync(Guid boardId, string requestingUserId, CancellationToken cancellationToken = default);
}
