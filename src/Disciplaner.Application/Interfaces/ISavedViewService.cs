using Disciplaner.Application.DTOs.SavedView;
using Disciplaner.Application.DTOs.Ticket;

namespace Disciplaner.Application.Interfaces;

public interface ISavedViewService
{
    Task<IReadOnlyList<SavedViewDto>> GetByUserAsync(string userId, CancellationToken cancellationToken = default);
    Task<SavedViewDto> CreateAsync(string userId, CreateSavedViewRequest request, CancellationToken cancellationToken = default);
    Task<SavedViewDto> UpdateAsync(Guid viewId, string userId, UpdateSavedViewRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid viewId, string userId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TicketDto>> ExecuteAsync(Guid viewId, string userId, CancellationToken cancellationToken = default);
}
