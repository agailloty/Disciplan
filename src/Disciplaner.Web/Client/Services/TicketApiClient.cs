using Disciplaner.Application.DTOs.Ticket;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class TicketApiClient
{
    private readonly HttpClient _http;

    public TicketApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<TicketDto>?> GetBacklogAsync(Guid projectId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<TicketDto>>($"/api/projects/{projectId}/tickets/backlog", ct);

    public Task<List<TicketDto>?> GetBySprintAsync(Guid sprintId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<TicketDto>>($"/api/sprints/{sprintId}/tickets", ct);

    public async Task<TicketDto?> CreateAsync(Guid projectId, CreateTicketRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/projects/{projectId}/tickets", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<TicketDto>();
    }

    public async Task UpdateAsync(Guid ticketId, UpdateTicketRequest request)
        => (await _http.PutAsJsonAsync($"/api/tickets/{ticketId}", request)).EnsureSuccessStatusCode();

    public async Task ChangeStatusAsync(Guid ticketId, ChangeTicketStatusRequest request)
        => (await _http.PutAsJsonAsync($"/api/tickets/{ticketId}/status", request)).EnsureSuccessStatusCode();

    public async Task MoveToSprintAsync(Guid ticketId, MoveTicketToSprintRequest request)
        => (await _http.PutAsJsonAsync($"/api/tickets/{ticketId}/sprint", request)).EnsureSuccessStatusCode();

    public async Task DeleteAsync(Guid ticketId)
        => (await _http.DeleteAsync($"/api/tickets/{ticketId}")).EnsureSuccessStatusCode();
}
