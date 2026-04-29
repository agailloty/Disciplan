using Disciplaner.Application.DTOs.Board;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class BoardApiClient
{
    // Uses the authenticated "Api" client — token injected by AuthHttpMessageHandler.
    private readonly HttpClient _http;

    public BoardApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<BoardSummaryDto>?> GetBoardsAsync(CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<BoardSummaryDto>>("/api/boards", ct);

    public Task<BoardDetailDto?> GetBoardAsync(Guid id, CancellationToken ct = default)
        => _http.GetFromJsonAsync<BoardDetailDto>($"/api/boards/{id}", ct);

    public async Task<BoardSummaryDto?> CreateBoardAsync(CreateBoardRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/boards", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<BoardSummaryDto>();
    }

    public async Task UpdateBoardAsync(Guid id, UpdateBoardRequest request)
        => (await _http.PutAsJsonAsync($"/api/boards/{id}", request)).EnsureSuccessStatusCode();

    public async Task DeleteBoardAsync(Guid id)
        => (await _http.DeleteAsync($"/api/boards/{id}")).EnsureSuccessStatusCode();
}
