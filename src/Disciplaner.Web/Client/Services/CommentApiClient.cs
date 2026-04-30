using Disciplaner.Application.DTOs.Comment;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class CommentApiClient
{
    private readonly HttpClient _http;

    public CommentApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public async Task<IReadOnlyList<CommentDto>> GetByCardAsync(Guid cardId)
    {
        var result = await _http.GetFromJsonAsync<List<CommentDto>>($"/api/cards/{cardId}/comments");
        return result?.AsReadOnly() ?? (IReadOnlyList<CommentDto>)[];
    }

    public async Task<IReadOnlyList<CommentDto>> GetByTicketAsync(Guid ticketId)
    {
        var result = await _http.GetFromJsonAsync<List<CommentDto>>($"/api/tickets/{ticketId}/comments");
        return result?.AsReadOnly() ?? (IReadOnlyList<CommentDto>)[];
    }

    public async Task<CommentDto?> CreateAsync(Guid cardId, CreateCommentRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/cards/{cardId}/comments", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CommentDto>();
    }

    public async Task<CommentDto?> CreateForTicketAsync(Guid ticketId, CreateCommentRequest request)
    {
        var response = await _http.PostAsJsonAsync($"/api/tickets/{ticketId}/comments", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CommentDto>();
    }

    public async Task<CommentDto?> UpdateAsync(Guid commentId, UpdateCommentRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/comments/{commentId}", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CommentDto>();
    }

    public async Task DeleteAsync(Guid commentId)
        => (await _http.DeleteAsync($"/api/comments/{commentId}")).EnsureSuccessStatusCode();
}
