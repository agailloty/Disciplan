using Disciplaner.Application.DTOs.Member;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class BoardMemberApiClient
{
    private readonly HttpClient _http;

    public BoardMemberApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<MemberDto>?> GetMembersAsync(Guid boardId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<MemberDto>>($"/api/boards/{boardId}/members", ct);

    public async Task<MemberDto?> AddMemberAsync(Guid boardId, AddMemberRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/boards/{boardId}/members", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<MemberDto>();
    }

    public async Task<MemberDto?> UpdateRoleAsync(Guid boardId, string userId, UpdateMemberRoleRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/boards/{boardId}/members/{userId}", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<MemberDto>();
    }

    public async Task RemoveMemberAsync(Guid boardId, string userId)
        => (await _http.DeleteAsync($"/api/boards/{boardId}/members/{userId}")).EnsureSuccessStatusCode();
}
