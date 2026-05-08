using Disciplaner.Application.DTOs.SavedView;
using Disciplaner.Application.DTOs.Ticket;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class SavedViewApiClient
{
    private readonly HttpClient _http;

    public SavedViewApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<SavedViewDto>?> GetAllAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<SavedViewDto>>("/api/saved-views", ct);

    public async Task<SavedViewDto?> CreateAsync(CreateSavedViewRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/saved-views", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<SavedViewDto>();
    }

    public async Task<SavedViewDto?> UpdateAsync(Guid viewId, UpdateSavedViewRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/saved-views/{viewId}", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<SavedViewDto>();
    }

    public async Task DeleteAsync(Guid viewId)
        => (await _http.DeleteAsync($"/api/saved-views/{viewId}")).EnsureSuccessStatusCode();

    public Task<List<TicketDto>?> ExecuteAsync(Guid viewId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<TicketDto>>($"/api/saved-views/{viewId}/tickets", ct);
}
