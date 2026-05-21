using Disciplaner.Application.DTOs.Attachment;
using Microsoft.AspNetCore.Components.Forms;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class AttachmentApiClient
{
    private readonly HttpClient _http;

    // Maximum file size accepted by the server (50 MB)
    private const long MaxFileSize = 52_428_800;

    public AttachmentApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    // ── Getters ────────────────────────────────────────────────────────────

    public async Task<IReadOnlyList<AttachmentDto>> GetByTicketAsync(Guid ticketId)
    {
        var result = await _http.GetFromJsonAsync<List<AttachmentDto>>($"/api/tickets/{ticketId}/attachments");
        return result?.AsReadOnly() ?? (IReadOnlyList<AttachmentDto>)[];
    }

    public async Task<IReadOnlyList<AttachmentDto>> GetByCommentAsync(Guid commentId)
    {
        var result = await _http.GetFromJsonAsync<List<AttachmentDto>>($"/api/comments/{commentId}/attachments");
        return result?.AsReadOnly() ?? (IReadOnlyList<AttachmentDto>)[];
    }

    public async Task<IReadOnlyList<AttachmentDto>> GetByBoardAsync(Guid boardId)
    {
        var result = await _http.GetFromJsonAsync<List<AttachmentDto>>($"/api/boards/{boardId}/attachments");
        return result?.AsReadOnly() ?? (IReadOnlyList<AttachmentDto>)[];
    }

    // ── Uploads ────────────────────────────────────────────────────────────

    public async Task<AttachmentDto?> UploadForTicketAsync(Guid ticketId, IBrowserFile file)
    {
        using var content = BuildMultipartContent(file);
        var response = await _http.PostAsync($"/api/tickets/{ticketId}/attachments", content);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AttachmentDto>();
    }

    public async Task<AttachmentDto?> UploadForCommentAsync(Guid commentId, IBrowserFile file)
    {
        using var content = BuildMultipartContent(file);
        var response = await _http.PostAsync($"/api/comments/{commentId}/attachments", content);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AttachmentDto>();
    }

    public async Task<AttachmentDto?> UploadForBoardAsync(Guid boardId, IBrowserFile file)
    {
        using var content = BuildMultipartContent(file);
        var response = await _http.PostAsync($"/api/boards/{boardId}/attachments", content);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AttachmentDto>();
    }

    // ── Download (authenticated – returns raw bytes) ───────────────────────

    public async Task<(byte[] Bytes, string ContentType)> DownloadAsync(Guid attachmentId)
    {
        var response = await _http.GetAsync($"/api/attachments/{attachmentId}/download");
        response.EnsureSuccessStatusCode();
        var bytes = await response.Content.ReadAsByteArrayAsync();
        var contentType = response.Content.Headers.ContentType?.MediaType ?? "application/octet-stream";
        return (bytes, contentType);
    }

    // ── Delete ─────────────────────────────────────────────────────────────

    public async Task DeleteAsync(Guid attachmentId)
        => (await _http.DeleteAsync($"/api/attachments/{attachmentId}")).EnsureSuccessStatusCode();

    // ── Helpers ────────────────────────────────────────────────────────────

    private static MultipartFormDataContent BuildMultipartContent(IBrowserFile file)
    {
        var content = new MultipartFormDataContent();
        var fileContent = new StreamContent(file.OpenReadStream(maxAllowedSize: MaxFileSize));
        fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue(file.ContentType);
        content.Add(fileContent, "file", file.Name);
        return content;
    }
}
