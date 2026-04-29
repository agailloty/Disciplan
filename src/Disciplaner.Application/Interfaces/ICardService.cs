using Disciplaner.Application.DTOs.Card;

namespace Disciplaner.Application.Interfaces;

public interface ICardService
{
    /// <summary>Returns all cards in a column, ordered by their position.</summary>
    Task<IReadOnlyList<CardDto>> GetByColumnAsync(Guid columnId, string requestingUserId, CancellationToken cancellationToken = default);

    /// <summary>Returns a single card by its id.</summary>
    Task<CardDto?> GetByIdAsync(Guid cardId, string requestingUserId, CancellationToken cancellationToken = default);

    /// <summary>Creates a new card at the bottom of the given column.</summary>
    Task<CardDto> CreateAsync(Guid columnId, string requestingUserId, CreateCardRequest request, CancellationToken cancellationToken = default);

    /// <summary>Updates the title, description, priority and due date of a card.</summary>
    Task<CardDto> UpdateAsync(Guid cardId, string requestingUserId, UpdateCardRequest request, CancellationToken cancellationToken = default);

    /// <summary>
    /// Moves a card to a different column and/or position.
    /// Handles both reordering within a column and cross-column moves.
    /// </summary>
    Task<CardDto> MoveAsync(Guid cardId, string requestingUserId, MoveCardRequest request, CancellationToken cancellationToken = default);

    /// <summary>Permanently deletes a card.</summary>
    Task DeleteAsync(Guid cardId, string requestingUserId, CancellationToken cancellationToken = default);
}
