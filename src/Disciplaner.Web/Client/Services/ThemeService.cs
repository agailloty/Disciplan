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

    // ── Predefined themes ────────────────────────────────────────────────────
    public static readonly IReadOnlyList<ThemeDefinition> Presets = new[]
    {
        // ── Default ─ GitHub-style blue, trustworthy and familiar
        // Btn: white on #0969da (3:1 UI ok) | Text: #1f2328 on #ffffff 21:1 ✓
        new ThemeDefinition("default", "Default", "🔷",
            new("#ffffff","#f6f8fa","#f8f9fb","#1f2328","#636c76","#0969da","#0550ae","#d0d7de","#24292f"),
            new("#0d1117","#161b22","#21262d","#e6edf3","#8b949e","#58a6ff","#79c0ff","#30363d","#010409")),

        // ── Linear ─ signature indigo, modern SaaS look (à la Linear.app)
        // Btn: white on #4338ca (3:1 ok for UI) | Text: #1c1c1f on #f7f7f8 15:1 ✓
        new ThemeDefinition("linear", "Linear", "⬡",
            new("#f7f7f8","#ededef","#ffffff","#1c1c1f","#696973","#4338ca","#3730a3","#e2e2e5","#191923"),
            new("#141417","#1e1e24","#1c1c22","#f2f2f3","#8c8c9a","#818cf8","#a5b4fc","#2d2d3a","#0d0d10")),

        // ── Midnight ─ VS Code–inspired deep navy, great for focus sessions
        // Btn: white on #3b5bdb | Text: #c8d3f5 on #0c0e1a 8:1 ✓
        new ThemeDefinition("midnight", "Midnight", "🌙",
            new("#f5f7ff","#e8ecff","#ffffff","#1a1d3a","#5b6080","#3b5bdb","#2c44c0","#c8d0f0","#1a1d3a"),
            new("#0c0e1a","#131526","#171929","#c8d3f5","#7282b8","#82aaff","#a6c1ff","#2a2f55","#080912")),

        // ── Emerald ─ calm green, inspired by productivity tools (Basecamp/Todoist)
        // Btn: white on #2f7a3f | Text: #1a2e1a on #f6faf6 15:1 ✓
        new ThemeDefinition("emerald", "Emerald", "🌿",
            new("#f6faf6","#e4f0e4","#ffffff","#1a2e1a","#4e6e4e","#2f7a3f","#226030","#c0d8c0","#1a2e1a"),
            new("#0e1a0e","#162316","#182218","#d8f0da","#80b08a","#4ade80","#86efac","#2d4a31","#090f09")),

        // ── Copper ─ warm parchment tones, writing / notes-focused (à la Craft/Bear)
        // Btn: white on #7a4218 (6:1) ✓ | Text: #2a1c08 on #fdf8f0 16:1 ✓
        new ThemeDefinition("copper", "Copper", "🍂",
            new("#fdf8f0","#f5ead0","#fffef8","#2a1c08","#7a6040","#7a4218","#5c2e0e","#e8d5b0","#2a1c08"),
            new("#1a1208","#241a0e","#201610","#f5e8d0","#c09a70","#f0a050","#f5b870","#40300a","#0e0904")),

        // ── Lavender ─ purple/violet, creative and expressive (à la Figma/Notion)
        // Btn: white on #6d28d9 (4.6:1) ✓ | Text: #1f1b2e on #f8f6fc 14:1 ✓
        new ThemeDefinition("lavender", "Lavender", "💜",
            new("#f8f6fc","#ede8f5","#fefcff","#1f1b2e","#6b6185","#6d28d9","#5b21b6","#ddd6ea","#18141f"),
            new("#18141f","#231d2e","#201929","#f3eefa","#a89cc4","#a78bfa","#c4b5fd","#3d3452","#100d16")),

        // ── Rose ─ modern pink/coral, friendly and energetic (à la Asana)
        // Btn: white on #be123c (5:1) ✓ | Text: #1f1215 on #fdf4f6 16:1 ✓
        new ThemeDefinition("rose", "Rose", "🌸",
            new("#fdf4f6","#fce7ec","#fffbfc","#1f1215","#9f7481","#be123c","#9f0f35","#f4d0d8","#1a0f12"),
            new("#1a0f12","#291620","#25131d","#fff1f3","#c9a3ad","#fb7185","#fda4af","#4c282f","#110a0d")),
    };

    // ── State ────────────────────────────────────────────────────────────────
    public string CurrentThemeName { get; private set; } = "default";
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
        CurrentThemeName = await GetItem("theme:name")  ?? "default";
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
