using Disciplaner.Application.DTOs.Member;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class ProjectMemberApiClient
{
    private readonly HttpClient _http;

    public ProjectMemberApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<MemberDto>?> GetMembersAsync(Guid projectId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<MemberDto>>($"/api/projects/{projectId}/members", ct);

    public async Task<MemberDto?> AddMemberAsync(Guid projectId, AddMemberRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/projects/{projectId}/members", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<MemberDto>();
    }

    public async Task<MemberDto?> UpdateRoleAsync(Guid projectId, string userId, UpdateMemberRoleRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/projects/{projectId}/members/{userId}", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<MemberDto>();
    }

    public async Task RemoveMemberAsync(Guid projectId, string userId)
        => (await _http.DeleteAsync($"/api/projects/{projectId}/members/{userId}")).EnsureSuccessStatusCode();
}
