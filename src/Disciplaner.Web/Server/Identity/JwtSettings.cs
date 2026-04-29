namespace Disciplaner.Web.Server.Identity;

public sealed class JwtSettings
{
    public const string SectionName = "Jwt";

    public string SecretKey { get; init; } = string.Empty;
    public string Issuer { get; init; } = "Disciplaner";
    public string Audience { get; init; } = "Disciplaner";
    public int ExpiryMinutes { get; init; } = 60;
}
