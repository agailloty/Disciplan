using Disciplaner.Application.DTOs.Activity;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class ActivityApiClient
{
    private readonly HttpClient _http;

    public ActivityApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    public Task<List<ActivityItemDto>?> GetRecentAsync(int limit = 20, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<ActivityItemDto>>($"/api/activity/recent?limit={limit}", ct);

    public Task<List<TicketActivityGroupDto>?> GetGroupedAsync(int limit = 20, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<TicketActivityGroupDto>>($"/api/activity/grouped?limit={limit}", ct);

    public Task<List<TicketHistoryEntryDto>?> GetTicketHistoryAsync(Guid ticketId, CancellationToken ct = default)
        => _http.GetFromJsonAsync<List<TicketHistoryEntryDto>>($"/api/tickets/{ticketId}/history", ct);
}
