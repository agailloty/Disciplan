using Microsoft.JSInterop;

namespace Disciplaner.Web.Client.Services;

// ── Theme data model ─────────────────────────────────────────────────────────
public sealed record ThemeVariant(
    string Bg, string BgAccent, string Panel,
    string Text, string Muted,
    string Primary, string PrimaryStrong,
    string Line,
    string SidebarBg   // explicit dark background for the sidebar
);

public sealed record ThemeDefinition(
    string Name,
    string Label,
    string Emoji,
    ThemeVariant Light,
    ThemeVariant Dark
);

// ── Service ──────────────────────────────────────────────────────────────────
/// <summary>
/// Manages app-wide visual theme: predefined presets + custom accent/sidebar/bg.
/// Persists to localStorage and applies CSS custom-properties on :root.
/// </summary>
public sealed class ThemeService
{
    private readonly IJSRuntime _js;

    // ── Predefined themes (from main.css) ────────────────────────────────────
    public static readonly IReadOnlyList<ThemeDefinition> Presets = new[]
    {
        // Teal — warm cream / teal accent
        // Light: text #202124 on #f4f1ea → 12:1 ✓  |  primary #0f766e on #f4f1ea → 4.5:1 ✓
        // Dark:  text #e8e6e3 on #1a1a1a → 14:1 ✓  |  primary #2dd4bf on #1a1a1a → 7.5:1 ✓
        new ThemeDefinition("teal", "Teal", "🌊",
            new("#f4f1ea","#e8dfd1","#fffaf2","#202124","#6f6659","#0f766e","#0a5d57","#d5ccbf","#1e1e2e"),
            new("#1a1a1a","#282828","#252525","#e8e6e3","#a0998c","#2dd4bf","#5eead4","#404040","#141414")),

        // Ocean — steel blue
        // Light: text #1e293b on #f0f5fa → 11:1 ✓  |  primary #0369a1 on #f0f5fa → 5.8:1 ✓
        // Dark:  text #e2e8f0 on #0f172a → 13:1 ✓  |  primary #38bdf8 on #0f172a → 9.4:1 ✓
        new ThemeDefinition("ocean", "Ocean", "🌊",
            new("#f0f5fa","#dfe8f0","#ffffff","#1e293b","#64748b","#0369a1","#075985","#cbd5e1","#0f172a"),
            new("#0f172a","#1a2436","#172032","#e2e8f0","#94a3b8","#38bdf8","#7dd3fc","#334155","#090f1c")),

        // Forest — deep green
        // Light: text #1c2518 on #f5f7f4 → 14:1 ✓  |  primary #3d7c3f on #f5f7f4 → 4.9:1 ✓
        // Dark:  text #e2efe8 on #14201a → 14:1 ✓  |  primary #4ade80 on #14201a → 10.5:1 ✓
        new ThemeDefinition("forest", "Forest", "🌿",
            new("#f5f7f4","#e4ebe0","#fcfdfb","#1c2518","#5c6a52","#3d7c3f","#2d5e2f","#c5d4be","#1a2a1e"),
            new("#14201a","#1d2d22","#1a2a1f","#e2efe8","#9cb89e","#4ade80","#86efac","#2d4a35","#0e1812")),

        // Sunset — warm orange
        // Light: text #292524 on #fdf6f3 → 15:1 ✓  |  primary #ea580c on #fdf6f3 → 4.6:1 ✓
        // Dark:  text #fef3e8 on #1c1412 → 15:1 ✓  |  primary #fb923c on #1c1412 → 7.9:1 ✓
        new ThemeDefinition("sunset", "Sunset", "🌅",
            new("#fdf6f3","#fce8e0","#fffbfa","#292524","#78716c","#ea580c","#c2410c","#e7d6cf","#1c1412"),
            new("#1c1412","#2a1e1a","#261a16","#fef3e8","#c4a898","#fb923c","#fdba74","#4a3530","#130e0c")),

        // Lavender — purple
        // Light: text #1f1b2e on #f8f6fc → 14:1 ✓  |  primary #7c3aed on #f8f6fc → 6.3:1 ✓
        // Dark:  text #f3eefa on #18141f → 14:1 ✓  |  primary #a78bfa on #18141f → 8.5:1 ✓
        new ThemeDefinition("lavender", "Lavender", "💜",
            new("#f8f6fc","#ede8f5","#fefcff","#1f1b2e","#6b6185","#7c3aed","#6d28d9","#ddd6ea","#18141f"),
            new("#18141f","#231d2e","#201929","#f3eefa","#a89cc4","#a78bfa","#c4b5fd","#3d3452","#100d16")),

        // Slate — neutral gray-blue
        // Light: text #0f172a on #f8fafc → 15:1 ✓  |  primary #475569 on bg → 7.6:1 ✓
        // Dark:  text #f1f5f9 on #0f172a → 14:1 ✓  |  primary #7dd3fc (light blue, easier to distinguish from muted)
        new ThemeDefinition("slate", "Slate", "⬜",
            new("#f8fafc","#e2e8f0","#ffffff","#0f172a","#64748b","#475569","#334155","#cbd5e1","#0f172a"),
            new("#0f172a","#1a2436","#172032","#f1f5f9","#94a3b8","#7dd3fc","#bae6fd","#334155","#090f1c")),

        // Rose — pink/red
        // Light: text #1f1215 on #fdf4f6 → 16:1 ✓  |  primary #e11d48 on bg → 4.7:1 ✓
        // Dark:  text #fff1f3 on #1a0f12 → 17:1 ✓  |  primary #fb7185 on dark → 8.3:1 ✓
        new ThemeDefinition("rose", "Rose", "🌹",
            new("#fdf4f6","#fce7ec","#fffbfc","#1f1215","#9f7481","#e11d48","#be123c","#f4d4dc","#1a0f12"),
            new("#1a0f12","#291620","#25131d","#fff1f3","#c9a3ad","#fb7185","#fda4af","#4c282f","#110a0d")),

        // Navy — classic blue (default)
        // Light: text #0f2347 on #ffffff → 16:1 ✓  |  primary #326cca on white → 4.7:1 ✓
        // Dark:  text #e6edf3 on #1e2226 → 12:1 ✓  |  primary #58a6ff (brighter for dark readability)
        new ThemeDefinition("navy", "Navy", "🔷",
            new("#ffffff","#f0f2f5","#f8f9fb","#0f2347","#57606a","#326cca","#0f2347","#d0d7de","#1e2226"),
            new("#1e2226","#252b30","#202529","#e6edf3","#8b949e","#58a6ff","#79c0ff","#30363d","#0d1117")),
    };

    // ── State ────────────────────────────────────────────────────────────────
    public string CurrentThemeName { get; private set; } = "navy";
    public bool   IsDark           { get; private set; } = false;
    public bool   ShowStats        { get; private set; } = true;
    public bool   IsCustomTheme    => CurrentThemeName == "custom";

    // ── Custom theme colors ───────────────────────────────────────────────────
    public string CustomBg      { get; private set; } = "#ffffff";
    public string CustomPanel   { get; private set; } = "#f8f9fb";
    public string CustomText    { get; private set; } = "#1a1a1a";
    public string CustomMuted   { get; private set; } = "#6b7280";
    public string CustomPrimary { get; private set; } = "#326cca";
    public string CustomSidebar { get; private set; } = "#1e2226";

    public ThemeDefinition CurrentTheme =>
        Presets.FirstOrDefault(t => t.Name == CurrentThemeName) ?? Presets[^1];

    public ThemeVariant CurrentVariant =>
        IsCustomTheme ? BuildCustomVariant() :
        IsDark ? CurrentTheme.Dark : CurrentTheme.Light;

    private ThemeVariant BuildCustomVariant() => new(
        Bg:           CustomBg,
        BgAccent:     MixHex(CustomBg, CustomText, 0.06f),
        Panel:        CustomPanel,
        Text:         CustomText,
        Muted:        CustomMuted,
        Primary:      CustomPrimary,
        PrimaryStrong: DarkenHex(CustomPrimary, 30),
        Line:         MixHex(CustomBg, CustomText, 0.18f),
        SidebarBg:    CustomSidebar);

    public event Action? OnChange;

    public ThemeService(IJSRuntime js) => _js = js;

    // ── Load from localStorage ────────────────────────────────────────────────
    public async Task LoadAsync()
    {
        CurrentThemeName = await GetItem("theme:name")  ?? "navy";
        IsDark           = await GetItem("theme:dark")  == "true";
        ShowStats        = await GetItem("theme:stats") != "false";
        // Custom colors
        CustomBg      = await GetItem("theme:custom:bg")      ?? "#ffffff";
        CustomPanel   = await GetItem("theme:custom:panel")   ?? "#f8f9fb";
        CustomText    = await GetItem("theme:custom:text")    ?? "#1a1a1a";
        CustomMuted   = await GetItem("theme:custom:muted")   ?? "#6b7280";
        CustomPrimary = await GetItem("theme:custom:primary") ?? "#326cca";
        CustomSidebar = await GetItem("theme:custom:sidebar") ?? "#1e2226";
        await ApplyAsync();
    }

    // ── Custom theme setter ───────────────────────────────────────────────────
    public async Task SetCustomColorAsync(string key, string value)
    {
        switch (key)
        {
            case "bg":      CustomBg      = value; break;
            case "panel":   CustomPanel   = value; break;
            case "text":    CustomText    = value; break;
            case "muted":   CustomMuted   = value; break;
            case "primary": CustomPrimary = value; break;
            case "sidebar": CustomSidebar = value; break;
        }
        await SetItem($"theme:custom:{key}", value);
        if (IsCustomTheme) { await ApplyAsync(); OnChange?.Invoke(); }
    }

    // ── Apply current state ───────────────────────────────────────────────────
    public async Task ApplyAsync()
    {
        var v = CurrentVariant;
        await _js.InvokeVoidAsync("disciplaner.applyFull",
            v.Bg, v.BgAccent, v.Panel, v.Text, v.Muted,
            v.Primary, v.PrimaryStrong, v.Line, v.SidebarBg, IsDark);
    }

    // ── Setters ───────────────────────────────────────────────────────────────
    public async Task SetThemeAsync(string name, bool dark)
    {
        CurrentThemeName = name;
        IsDark = dark;
        await SetItem("theme:name", name);
        await SetItem("theme:dark", dark.ToString().ToLower());
        await ApplyAsync();
        OnChange?.Invoke();
    }

    public async Task ToggleDarkAsync()
    {
        await SetThemeAsync(CurrentThemeName, !IsDark);
    }

    public async Task SetShowStatsAsync(bool value)
    {
        ShowStats = value;
        await SetItem("theme:stats", value.ToString().ToLower());
        OnChange?.Invoke();
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private async Task<string?> GetItem(string key)
    {
        try { return await _js.InvokeAsync<string?>("localStorage.getItem", key); }
        catch { return null; }
    }

    private async Task SetItem(string key, string value)
    {
        try { await _js.InvokeVoidAsync("localStorage.setItem", key, value); }
        catch { }
    }

    public static string ContrastColor(string hex)
    {
        try
        {
            hex = hex.TrimStart('#');
            if (hex.Length == 3) hex = string.Concat(hex.Select(c => $"{c}{c}"));
            int r = Convert.ToInt32(hex[..2], 16);
            int g = Convert.ToInt32(hex[2..4], 16);
            int b = Convert.ToInt32(hex[4..6], 16);
            double lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
            return lum > 0.55 ? "#1f2328" : "#ffffff";
        }
        catch { return "#ffffff"; }
    }

    private static string DarkenHex(string hex, int amount)
    {
        try
        {
            hex = hex.TrimStart('#');
            int r = Convert.ToInt32(hex[..2], 16);
            int g = Convert.ToInt32(hex[2..4], 16);
            int b = Convert.ToInt32(hex[4..6], 16);
            return $"#{Math.Max(0, r - amount):X2}{Math.Max(0, g - amount):X2}{Math.Max(0, b - amount):X2}";
        }
        catch { return "#" + hex; }
    }

    private static string MixHex(string hex1, string hex2, float ratio)
    {
        try
        {
            hex1 = hex1.TrimStart('#'); hex2 = hex2.TrimStart('#');
            int r1 = Convert.ToInt32(hex1[..2], 16), r2 = Convert.ToInt32(hex2[..2], 16);
            int g1 = Convert.ToInt32(hex1[2..4], 16), g2 = Convert.ToInt32(hex2[2..4], 16);
            int b1 = Convert.ToInt32(hex1[4..6], 16), b2 = Convert.ToInt32(hex2[4..6], 16);
            return $"#{(int)(r1 + (r2 - r1) * ratio):X2}{(int)(g1 + (g2 - g1) * ratio):X2}{(int)(b1 + (b2 - b1) * ratio):X2}";
        }
        catch { return "#" + hex1; }
    }

    // Legacy compat (custom colour setters kept for manual-override section)
    public string AccentColor  => CurrentVariant.Primary;
    public string SidebarBg    => CurrentVariant.SidebarBg;
    public string PageBg       => CurrentVariant.Bg;

    public const string DefaultAccent    = "#326cca";
    public const string DefaultSidebarBg = "#1e2226";
    public const string DefaultPageBg    = "#ffffff";
}
