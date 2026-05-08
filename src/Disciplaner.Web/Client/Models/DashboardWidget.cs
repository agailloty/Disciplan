namespace Disciplaner.Web.Client.Models;

/// <summary>
/// Represents a slot in the home-page dashboard.
/// Kind values: "my_tickets" | "recent_activity" | "saved_view"
/// </summary>
public sealed record DashboardWidget(
    string Kind,
    Guid? ViewId,
    int Order,
    bool Visible);
