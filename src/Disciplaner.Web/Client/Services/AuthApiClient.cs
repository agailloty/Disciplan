using Disciplaner.Application.DTOs.Auth;
using Disciplaner.Web.Client.Auth;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class AuthApiClient
{
    // Uses the unauthenticated "Public" client — login/register don't need a token.
    private readonly HttpClient _http;
    private readonly TokenStorageService _tokenStorage;
    private readonly JwtAuthStateProvider _authProvider;

    public AuthApiClient(
        IHttpClientFactory factory,
        TokenStorageService tokenStorage,
        JwtAuthStateProvider authProvider)
    {
        _http = factory.CreateClient("Public");
        _tokenStorage = tokenStorage;
        _authProvider = authProvider;
    }

    public async Task<(AuthResponse? Response, string? Error)> LoginAsync(LoginRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/auth/login", request);
        if (!response.IsSuccessStatusCode)
            return (null, "Email ou mot de passe invalide.");

        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        if (auth is null) return (null, "Réponse inattendue du serveur.");

        await _tokenStorage.SetTokenAsync(auth.Token);
        _authProvider.NotifyUserAuthenticated(auth.Token);
        return (auth, null);
    }

    public async Task<(AuthResponse? Response, string? Error)> RegisterAsync(RegisterRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/auth/register", request);
        if (!response.IsSuccessStatusCode)
            return (null, "L'inscription a échoué. Vérifiez les informations saisies.");

        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        if (auth is null) return (null, "Réponse inattendue du serveur.");

        await _tokenStorage.SetTokenAsync(auth.Token);
        _authProvider.NotifyUserAuthenticated(auth.Token);
        return (auth, null);
    }

    public async Task LogoutAsync()
    {
        await _tokenStorage.RemoveTokenAsync();
        _authProvider.NotifyUserLoggedOut();
    }

    // ── First-run setup ───────────────────────────────────────────────────────

    public async Task<bool> IsSetupRequiredAsync()
    {
        try
        {
            var status = await _http.GetFromJsonAsync<SetupStatusResponse>("/api/setup/status");
            return status?.SetupRequired ?? false;
        }
        catch { return false; }
    }

    public async Task<(AuthResponse? Response, string? Error)> SetupAsync(SetupRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/setup", request);
        if (!response.IsSuccessStatusCode)
            return (null, "La configuration initiale a échoué. Vérifiez les informations saisies.");

        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        if (auth is null) return (null, "Réponse inattendue du serveur.");

        await _tokenStorage.SetTokenAsync(auth.Token);
        _authProvider.NotifyUserAuthenticated(auth.Token);
        return (auth, null);
    }

    // ── Invitation-based registration ─────────────────────────────────────────

    public Task<InvitationInfoResponse?> GetInvitationInfoAsync(string token)
        => _http.GetFromJsonAsync<InvitationInfoResponse>($"/api/auth/invitation/{token}");

    public async Task<(AuthResponse? Response, string? Error)> RegisterInvitedAsync(InvitationRegisterRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/auth/register-invited", request);
        if (!response.IsSuccessStatusCode)
        {
            try
            {
                var problem = await response.Content.ReadFromJsonAsync<System.Text.Json.JsonElement>();
                var msg = problem.TryGetProperty("message", out var m) ? m.GetString() : null;
                return (null, msg ?? "L'inscription a échoué.");
            }
            catch { return (null, "L'inscription a échoué."); }
        }

        var auth = await response.Content.ReadFromJsonAsync<AuthResponse>();
        if (auth is null) return (null, "Réponse inattendue du serveur.");

        await _tokenStorage.SetTokenAsync(auth.Token);
        _authProvider.NotifyUserAuthenticated(auth.Token);
        return (auth, null);
    }
}
