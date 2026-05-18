using Disciplaner.Web.Client.Models;
using Microsoft.JSInterop;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Disciplaner.Web.Client.Services;

public sealed class DashboardConfigService
{
    private readonly IJSRuntime _js;
    private const string Key = "disciplaner-dashboard-v1";

    private static readonly JsonSerializerOptions _opts = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter() }
    };

    public DashboardConfigService(IJSRuntime js) => _js = js;

    public async Task<List<DashboardWidget>> LoadAsync()
    {
        try
        {
            var json = await _js.InvokeAsync<string?>("localStorage.getItem", Key);
            if (!string.IsNullOrEmpty(json))
                return JsonSerializer.Deserialize<List<DashboardWidget>>(json, _opts) ?? Defaults();
        }
        catch { }
        return Defaults();
    }

    public async Task SaveAsync(IEnumerable<DashboardWidget> widgets)
    {
        try
        {
            var json = JsonSerializer.Serialize(widgets.ToList(), _opts);
            await _js.InvokeVoidAsync("localStorage.setItem", Key, json);
        }
        catch { }
    }

    /// <summary>
    /// Merges stored config with current saved view IDs:
    /// - removes widgets referencing deleted views
    /// - appends new views not yet in config (visible by default, order at end)
    /// - inserts any built-in widgets from Defaults() that are missing from stored config
    /// </summary>
    public static List<DashboardWidget> Merge(List<DashboardWidget> stored, IEnumerable<Guid> savedViewIds)
    {
        var viewIds = savedViewIds.ToHashSet();

        var result = stored
            .Where(w => w.Kind != "saved_view" || viewIds.Contains(w.ViewId!.Value))
            .ToList();

        // Insert any built-in widgets that are missing (e.g. newly added defaults)
        foreach (var def in Defaults())
        {
            if (!result.Any(w => w.Kind == def.Kind))
                result.Add(def);
        }

        var nextOrder = result.Count > 0 ? result.Max(w => w.Order) + 10 : 20;

        foreach (var id in viewIds)
        {
            if (!result.Any(w => w.Kind == "saved_view" && w.ViewId == id))
            {
                result.Add(new DashboardWidget("saved_view", id, nextOrder, true));
                nextOrder += 10;
            }
        }

        return [.. result.OrderBy(w => w.Order)];
    }

    public static List<DashboardWidget> Defaults() =>
    [
        new("my_tickets",      null, 0,  true),
        new("active_sprints",  null, 5,  true),
        new("recent_activity", null, 10, true)
    ];

    /// <summary>Returns a stable string key for a widget (used for expansion tracking).</summary>
    public static string WidgetKey(DashboardWidget w) =>
        w.Kind == "saved_view" ? $"saved_view:{w.ViewId}" : w.Kind;
}
