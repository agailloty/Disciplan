using Disciplaner.Application.DTOs.Auth;
using Disciplaner.Application.DTOs.User;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

/// <summary>API client for admin-only user and invitation management endpoints.</summary>
public sealed class AdminApiClient
{
    private readonly HttpClient _http;

    public AdminApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    // ── Users ─────────────────────────────────────────────────────────────────

    public Task<List<AdminUserDto>?> GetUsersAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<AdminUserDto>>("/api/admin/users", ct);

    public async Task<(AdminUserDto? User, string? Error)> CreateUserAsync(CreateUserRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/admin/users", request);
        if (!response.IsSuccessStatusCode)
            return (null, "La création de l'utilisateur a échoué.");
        var dto = await response.Content.ReadFromJsonAsync<AdminUserDto>();
        return (dto, null);
    }

    public async Task<bool> DeactivateUserAsync(string id)
    {
        var response = await _http.PostAsync($"/api/admin/users/{id}/deactivate", null);
        return response.IsSuccessStatusCode;
    }

    public async Task<bool> ActivateUserAsync(string id)
    {
        var response = await _http.PostAsync($"/api/admin/users/{id}/activate", null);
        return response.IsSuccessStatusCode;
    }

    public async Task<bool> ChangeRoleAsync(string id, string role)
    {
        var response = await _http.PutAsJsonAsync($"/api/admin/users/{id}/role", new ChangeUserRoleRequest(role));
        return response.IsSuccessStatusCode;
    }

    // ── Invitations ───────────────────────────────────────────────────────────

    public Task<List<InvitationDto>?> GetInvitationsAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<InvitationDto>>("/api/admin/invitations", ct);

    public async Task<(InvitationDto? Invitation, string? Error)> CreateInvitationAsync(string? email)
    {
        var response = await _http.PostAsJsonAsync("/api/admin/invitations", new InviteUserRequest(email));
        if (!response.IsSuccessStatusCode)
            return (null, "La création de l'invitation a échoué.");
        var dto = await response.Content.ReadFromJsonAsync<InvitationDto>();
        return (dto, null);
    }
}
