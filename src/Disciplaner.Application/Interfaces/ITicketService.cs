using Disciplaner.Application.DTOs.Ticket;

namespace Disciplaner.Application.Interfaces;

public interface ITicketService
{
    Task<IReadOnlyList<TicketDto>> GetBacklogAsync(Guid projectId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TicketDto>> GetBySprintAsync(Guid sprintId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<TicketDto?> GetByIdAsync(Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default);
    Task<TicketDto?> GetByRefAsync(string projectKey, int ticketNumber, string requestingUserId, CancellationToken cancellationToken = default);
    Task<TicketDto> CreateAsync(Guid projectId, string requestingUserId, CreateTicketRequest request, CancellationToken cancellationToken = default);
    Task<TicketDto> UpdateAsync(Guid ticketId, string requestingUserId, UpdateTicketRequest request, CancellationToken cancellationToken = default);
    Task<TicketDto> ChangeStatusAsync(Guid ticketId, string requestingUserId, ChangeTicketStatusRequest request, CancellationToken cancellationToken = default);
    Task<TicketDto> MoveToSprintAsync(Guid ticketId, string requestingUserId, MoveTicketToSprintRequest request, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TicketDto>> GetAssignedToMeAsync(string userId, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default);
}
