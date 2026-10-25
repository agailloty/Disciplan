using System.Security.Cryptography;
using System.Text;

namespace Disciplaner.Domain.Common;

/// <summary>
/// Raw generation and salted hashing of MCP personal access tokens (PAT).
/// Token format: <c>dcp_</c> + base64url(16-byte salt) + <c>.</c> + base64url(32-byte secret).
/// Only <c>SHA256(salt || secret)</c> is persisted; the raw value is shown once at creation.
/// The salt is embedded in the raw token so a hash lookup stays a single indexed query.
/// </summary>
public static class McpTokenSecurity
{
    public const string RawPrefix = "dcp_";
    public const string ReadScope = "read";
    public const string ReadWriteScope = "read+write";

    public static readonly string[] AllScopes = [ReadScope, ReadWriteScope];

    /// <summary>Generates a new raw token and its salted, persisted hash.</summary>
    public static (string Raw, string Hash) Generate()
    {
        var salt = new byte[16];
        var secret = new byte[32];
        RandomNumberGenerator.Fill(salt);
        RandomNumberGenerator.Fill(secret);

        var raw = $"{RawPrefix}{ToBase64Url(salt)}.{ToBase64Url(secret)}";
        return (raw, Hash(salt, secret));
    }

    /// <summary>
    /// Computes the persisted hash for a raw token, or null when the value is not a
    /// well-formed Disciplaner PAT. Constant-shape parsing: no early exit on unknown prefix.
    /// </summary>
    public static string? HashOf(string? rawToken)
    {
        if (string.IsNullOrEmpty(rawToken) || !rawToken.StartsWith(RawPrefix, StringComparison.Ordinal))
            return null;

        var body = rawToken[RawPrefix.Length..];
        var separator = body.IndexOf('.');
        if (separator <= 0 || separator == body.Length - 1) return null;

        var salt = FromBase64Url(body[..separator]);
        var secret = FromBase64Url(body[(separator + 1)..]);
        if (salt is null || secret is null) return null;

        return Hash(salt, secret);
    }

    public static bool IsValidScope(string? scope)
        => scope == ReadScope || scope == ReadWriteScope;

    private static string Hash(byte[] salt, byte[] secret)
    {
        var input = new byte[salt.Length + secret.Length];
        salt.CopyTo(input, 0);
        secret.CopyTo(input, salt.Length);
        return Convert.ToBase64String(SHA256.HashData(input));
    }

    private static string ToBase64Url(byte[] bytes)
        => Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static byte[]? FromBase64Url(string value)
    {
        var base64 = value.Replace('-', '+').Replace('_', '/');
        base64 = (base64.Length % 4) switch
        {
            2 => base64 + "==",
            3 => base64 + "=",
            _ => base64
        };
        try { return Convert.FromBase64String(base64); }
        catch (FormatException) { return null; }
    }
}
