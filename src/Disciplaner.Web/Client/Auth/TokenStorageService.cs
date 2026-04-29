using Microsoft.JSInterop;

namespace Disciplaner.Web.Client.Auth;

/// <summary>
/// Wraps localStorage via JS interop to persist the JWT across page reloads.
/// localStorage is preferred over sessionStorage for homelab UX (token survives tab refresh).
/// </summary>
public sealed class TokenStorageService
{
    private const string Key = "disciplaner_auth_token";
    private readonly IJSRuntime _js;

    public TokenStorageService(IJSRuntime js) => _js = js;

    public ValueTask<string?> GetTokenAsync()
        => _js.InvokeAsync<string?>("localStorage.getItem", Key);

    public ValueTask SetTokenAsync(string token)
        => _js.InvokeVoidAsync("localStorage.setItem", Key, token);

    public ValueTask RemoveTokenAsync()
        => _js.InvokeVoidAsync("localStorage.removeItem", Key);
}
