using System.Net.Http.Headers;

namespace Disciplaner.Web.Client.Auth;

/// <summary>
/// Injects the stored JWT as a Bearer header on every outgoing request to the API.
/// Registered only on the named "Api" HttpClient, never on the "Public" client.
/// </summary>
public sealed class AuthHttpMessageHandler : DelegatingHandler
{
    private readonly TokenStorageService _tokenStorage;

    public AuthHttpMessageHandler(TokenStorageService tokenStorage)
        => _tokenStorage = tokenStorage;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await _tokenStorage.GetTokenAsync();
        if (!string.IsNullOrWhiteSpace(token))
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        return await base.SendAsync(request, cancellationToken);
    }
}
