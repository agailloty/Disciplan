namespace Disciplaner.Web.Server.Identity;

public sealed class JwtSettings
{
    public const string SectionName = "Jwt";

    public string SecretKey { get; init; } = string.Empty;
    public string Issuer { get; init; } = "Disciplaner";
    public string Audience { get; init; } = "Disciplaner";
    public int ExpiryMinutes { get; init; } = 60;

    /// <summary>
    /// A JWT expired for less than this many days can be exchanged for a fresh
    /// one via POST /api/auth/refresh. Acts as a sliding session window so
    /// infrequent clients (mobile/desktop apps left idle) stay signed in.
    /// </summary>
    public int RefreshWindowDays { get; init; } = 30;
}
