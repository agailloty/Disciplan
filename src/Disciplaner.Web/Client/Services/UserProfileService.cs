namespace Disciplaner.Web.Client.Services;

/// <summary>
/// Client-side cache for the current user's mutable profile data (e.g. display name).
/// Avoids re-reading stale JWT claims after in-session updates.
/// </summary>
public sealed class UserProfileService
{
    private string? _displayName;

    public string? DisplayName => _displayName;

    /// <summary>Raised whenever the display name changes.</summary>
    public event Action? OnChange;

    public void SetDisplayName(string displayName)
    {
        _displayName = displayName;
        OnChange?.Invoke();
    }
}
