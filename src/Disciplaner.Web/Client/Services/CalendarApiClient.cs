using Disciplaner.Application.DTOs.Calendar;
using System.Net;
using System.Net.Http.Json;

namespace Disciplaner.Web.Client.Services;

public sealed class CalendarApiClient
{
    private readonly HttpClient _http;

    public CalendarApiClient(IHttpClientFactory factory)
        => _http = factory.CreateClient("Api");

    /// <summary>Returns the current token, or null if none has been generated.</summary>
    public async Task<CalendarTokenDto?> GetTokenAsync(CancellationToken ct = default)
    {
        var response = await _http.GetAsync("/api/calendar/token", ct);
        if (response.StatusCode == HttpStatusCode.NotFound) return null;
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CalendarTokenDto>(ct);
    }

    /// <summary>Generates (or replaces) the calendar token.</summary>
    public async Task<CalendarTokenDto?> GenerateTokenAsync(CancellationToken ct = default)
    {
        var response = await _http.PostAsync("/api/calendar/token", null, ct);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CalendarTokenDto>(ct);
    }

    /// <summary>Revokes the calendar token so the current subscription URL becomes invalid.</summary>
    public async Task RevokeTokenAsync(CancellationToken ct = default)
        => (await _http.DeleteAsync("/api/calendar/token", ct)).EnsureSuccessStatusCode();
}
