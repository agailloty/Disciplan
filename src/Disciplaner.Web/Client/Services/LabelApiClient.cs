using Disciplaner.Application.DTOs.Label;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class LabelApiClient
{
    private readonly HttpClient _http;

    public LabelApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<LabelDto>?> GetLabelsAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<LabelDto>>("/api/labels", ct);

    public Task<LabelDto?> GetLabelAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<LabelDto>($"/api/labels/{id}", ct);

    public Task<LabelItemsDto?> GetItemsAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<LabelItemsDto>($"/api/labels/{id}/items", ct);

    public async Task<LabelDto?> CreateLabelAsync(CreateLabelRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/labels", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<LabelDto>();
    }

    public async Task<LabelDto?> UpdateLabelAsync(Guid id, UpdateLabelRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/labels/{id}", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<LabelDto>();
    }

    public async Task DeleteLabelAsync(Guid id)
        => (await _http.DeleteAsync($"/api/labels/{id}")).EnsureSuccessStatusCode();

    public async Task AttachToTicketAsync(Guid labelId, Guid ticketId)
        => (await _http.PostAsync($"/api/labels/{labelId}/tickets/{ticketId}", null)).EnsureSuccessStatusCode();

    public async Task DetachFromTicketAsync(Guid labelId, Guid ticketId)
        => (await _http.DeleteAsync($"/api/labels/{labelId}/tickets/{ticketId}")).EnsureSuccessStatusCode();

    public async Task AttachToBoardAsync(Guid labelId, Guid boardId)
        => (await _http.PostAsync($"/api/labels/{labelId}/boards/{boardId}", null)).EnsureSuccessStatusCode();

    public async Task DetachFromBoardAsync(Guid labelId, Guid boardId)
        => (await _http.DeleteAsync($"/api/labels/{labelId}/boards/{boardId}")).EnsureSuccessStatusCode();
}
