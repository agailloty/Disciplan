using Disciplaner.Application.DTOs.Card;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class CardApiClient
{
    private readonly HttpClient _http;

    public CardApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public async Task<CardDto?> CreateAsync(Guid columnId, CreateCardRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/columns/{columnId}/cards", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CardDto>();
    }

    public async Task UpdateAsync(Guid cardId, UpdateCardRequest request)
        => (await _http.PutAsJsonAsync($"/api/cards/{cardId}", request)).EnsureSuccessStatusCode();

    public async Task DeleteAsync(Guid cardId)
        => (await _http.DeleteAsync($"/api/cards/{cardId}")).EnsureSuccessStatusCode();

    public async Task MoveCardAsync(Guid cardId, MoveCardRequest request)
        => (await _http.PutAsJsonAsync($"/api/cards/{cardId}/move", request)).EnsureSuccessStatusCode();
}
