using Disciplaner.Application.DTOs.Sprint;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class SprintApiClient
{
    private readonly HttpClient _http;

    public SprintApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<SprintDto>?> GetActiveForUserAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<SprintDto>>("/api/sprints/active", ct);

    public Task<SprintDetailDto?> GetSprintAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<SprintDetailDto>($"/api/sprints/{id}", ct);

    public Task<List<SprintDto>?> GetByProjectAsync(Guid projectId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<SprintDto>>($"/api/projects/{projectId}/sprints", ct);

    public async Task<SprintDto?> CreateAsync(Guid projectId, CreateSprintRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/projects/{projectId}/sprints", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<SprintDto>();
    }

    public async Task UpdateAsync(Guid sprintId, UpdateSprintRequest request)
        => (await _http.PutAsJsonAsync($"/api/sprints/{sprintId}", request)).EnsureSuccessStatusCode();

    public async Task StartAsync(Guid sprintId, StartSprintRequest request)
        => (await _http.PutAsJsonAsync($"/api/sprints/{sprintId}/start", request)).EnsureSuccessStatusCode();

    public async Task CloseAsync(Guid sprintId)
        => (await _http.PutAsJsonAsync($"/api/sprints/{sprintId}/close", new { })).EnsureSuccessStatusCode();

    public async Task DeleteAsync(Guid sprintId)
        => (await _http.DeleteAsync($"/api/sprints/{sprintId}")).EnsureSuccessStatusCode();
}
