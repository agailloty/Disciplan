using Disciplaner.Application.DTOs.Project;
using Disciplaner.Application.DTOs.TicketStatus;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class ProjectApiClient
{
    private readonly HttpClient _http;

    public ProjectApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<ProjectSummaryDto>?> GetProjectsAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<ProjectSummaryDto>>("/api/projects", ct);

    public Task<ProjectDetailDto?> GetProjectAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<ProjectDetailDto>($"/api/projects/{id}", ct);

    public async Task<ProjectDetailDto?> CreateProjectAsync(CreateProjectRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/projects", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<ProjectDetailDto>();
    }

    public async Task UpdateProjectAsync(Guid id, UpdateProjectRequest request)
        => (await _http.PutAsJsonAsync($"/api/projects/{id}", request)).EnsureSuccessStatusCode();

    public async Task DeleteProjectAsync(Guid id)
        => (await _http.DeleteAsync($"/api/projects/{id}")).EnsureSuccessStatusCode();

    public async Task<TicketStatusDto?> AddStatusAsync(Guid projectId, CreateTicketStatusRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/projects/{projectId}/statuses", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<TicketStatusDto>();
    }

    public async Task UpdateStatusAsync(Guid projectId, Guid statusId, UpdateTicketStatusRequest request)
        => (await _http.PutAsJsonAsync($"/api/projects/{projectId}/statuses/{statusId}", request)).EnsureSuccessStatusCode();

    public async Task DeleteStatusAsync(Guid projectId, Guid statusId)
        => (await _http.DeleteAsync($"/api/projects/{projectId}/statuses/{statusId}")).EnsureSuccessStatusCode();
}
