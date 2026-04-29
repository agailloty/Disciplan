using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Components.Authorization;

namespace Disciplaner.Web.Client.Auth;

/// <summary>
/// Custom AuthenticationStateProvider that reads the JWT from localStorage,
/// parses its claims, and returns an authenticated ClaimsPrincipal.
///
/// No server round-trip is required: the token is validated locally (expiry
/// is checked by comparing the "exp" claim to UtcNow).
/// </summary>
public sealed class JwtAuthStateProvider : AuthenticationStateProvider
{
    private readonly TokenStorageService _tokenStorage;

    private static readonly AuthenticationState Anonymous =
        new(new ClaimsPrincipal(new ClaimsIdentity()));

    public JwtAuthStateProvider(TokenStorageService tokenStorage)
        => _tokenStorage = tokenStorage;

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        var token = await _tokenStorage.GetTokenAsync();
        if (string.IsNullOrWhiteSpace(token))
            return Anonymous;

        var claims = ParseClaimsFromJwt(token);
        if (IsTokenExpired(claims))
        {
            await _tokenStorage.RemoveTokenAsync();
            return Anonymous;
        }

        var identity = new ClaimsIdentity(claims, authenticationType: "jwt");
        return new AuthenticationState(new ClaimsPrincipal(identity));
    }

    /// <summary>Called after a successful login/register to immediately update the UI.</summary>
    public void NotifyUserAuthenticated(string token)
    {
        var claims = ParseClaimsFromJwt(token);
        var identity = new ClaimsIdentity(claims, authenticationType: "jwt");
        var state = new AuthenticationState(new ClaimsPrincipal(identity));
        NotifyAuthenticationStateChanged(Task.FromResult(state));
    }

    /// <summary>Called on logout to immediately revert to anonymous state.</summary>
    public void NotifyUserLoggedOut()
        => NotifyAuthenticationStateChanged(Task.FromResult(Anonymous));

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var payload = jwt.Split('.')[1];
        // Base64url → standard Base64
        var base64 = payload.Replace('-', '+').Replace('_', '/')
                            .PadRight(payload.Length + (4 - payload.Length % 4) % 4, '=');

        var jsonBytes = Convert.FromBase64String(base64);
        var pairs = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(jsonBytes)!;

        return pairs.SelectMany(kvp =>
            kvp.Value.ValueKind == JsonValueKind.Array
                ? kvp.Value.EnumerateArray().Select(v => new Claim(kvp.Key, v.ToString()))
                : (IEnumerable<Claim>)[new Claim(kvp.Key, kvp.Value.ToString())]);
    }

    private static bool IsTokenExpired(IEnumerable<Claim> claims)
    {
        var exp = claims.FirstOrDefault(c => c.Type == "exp")?.Value;
        if (exp is null) return false;
        var expiry = DateTimeOffset.FromUnixTimeSeconds(long.Parse(exp));
        return expiry < DateTimeOffset.UtcNow;
    }
}
