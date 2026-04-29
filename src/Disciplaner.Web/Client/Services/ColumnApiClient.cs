using Disciplaner.Application.DTOs.Column;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class ColumnApiClient
{
    private readonly HttpClient _http;

    public ColumnApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public async Task<ColumnDto?> CreateAsync(Guid boardId, CreateColumnRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/boards/{boardId}/columns", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<ColumnDto>();
    }

    public async Task UpdateAsync(Guid columnId, UpdateColumnRequest request)
        => (await _http.PutAsJsonAsync($"/api/columns/{columnId}", request)).EnsureSuccessStatusCode();

    public async Task DeleteAsync(Guid columnId)
        => (await _http.DeleteAsync($"/api/columns/{columnId}")).EnsureSuccessStatusCode();
}
