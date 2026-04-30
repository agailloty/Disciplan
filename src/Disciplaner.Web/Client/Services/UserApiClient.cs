using Disciplaner.Application.DTOs.User;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class UserApiClient
{
    private readonly HttpClient _http;

    public UserApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<UserSummaryDto>?> GetAllAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<UserSummaryDto>>("/api/users", ct);
}
