using System.Security.Cryptography;
using System.Text;

namespace Disciplaner.Domain.Common;

/// <summary>
/// Cryptographic helpers, constants and token generators for OAuth 2.1 authentication on MCP.
/// Follows RFC 6749, RFC 7636 (PKCE), RFC 7591 (DCR), and RFC 9728 (Protected Resource Metadata).
/// </summary>
public static class McpOAuthSecurity
{
    public const string ClientIdPrefix = "dcp_client_";
    public const string ClientSecretPrefix = "dcp_cs_";
    public const string AuthorizationCodePrefix = "dcp_code_";
    public const string AccessTokenPrefix = "dcp_at_";
    public const string RefreshTokenPrefix = "dcp_rt_";

    public const string PkceMethodS256 = "S256";

    public static string GenerateClientId() =>
        ClientIdPrefix + GenerateRandomUrlSafeString(24);

    public static string GenerateClientSecret() =>
        ClientSecretPrefix + GenerateRandomUrlSafeString(32);

    public static string GenerateAuthorizationCode() =>
        AuthorizationCodePrefix + GenerateRandomUrlSafeString(32);

    public static string GenerateAccessToken() =>
        AccessTokenPrefix + GenerateRandomUrlSafeString(32);

    public static string GenerateRefreshToken() =>
        RefreshTokenPrefix + GenerateRandomUrlSafeString(32);

    /// <summary>
    /// Generates a cryptographically secure random Base64URL-encoded string without padding.
    /// </summary>
    public static string GenerateRandomUrlSafeString(int byteLength)
    {
        Span<byte> bytes = stackalloc byte[byteLength];
        RandomNumberGenerator.Fill(bytes);
        return Convert.ToBase64String(bytes)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
    }

    /// <summary>
    /// Computes the hexadecimal SHA-256 hash of a string.
    /// </summary>
    public static string Sha256(string input)
    {
        ArgumentNullException.ThrowIfNull(input);
        var bytes = Encoding.UTF8.GetBytes(input);
        var hash = SHA256.HashData(bytes);
        return Convert.ToHexStringLower(hash);
    }

    /// <summary>
    /// Validates PKCE challenge according to RFC 7636 Section 4.6.
    /// MCP / OAuth 2.1 mandates code_challenge_method = S256.
    /// </summary>
    public static bool VerifyPkce(string codeVerifier, string codeChallenge, string? codeChallengeMethod)
    {
        if (string.IsNullOrWhiteSpace(codeVerifier) || string.IsNullOrWhiteSpace(codeChallenge))
            return false;

        var method = string.IsNullOrWhiteSpace(codeChallengeMethod) ? PkceMethodS256 : codeChallengeMethod;
        if (!string.Equals(method, PkceMethodS256, StringComparison.OrdinalIgnoreCase))
            return false;

        var verifierBytes = Encoding.ASCII.GetBytes(codeVerifier);
        var hash = SHA256.HashData(verifierBytes);
        var computedChallenge = Convert.ToBase64String(hash)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');

        return CryptographicOperations.FixedTimeEquals(
            Encoding.ASCII.GetBytes(computedChallenge),
            Encoding.ASCII.GetBytes(codeChallenge));
    }

    /// <summary>
    /// Normalizes and validates requested scopes against supported MCP scopes (read, read+write).
    /// </summary>
    public static bool TryNormalizeScopes(string? requestedScopes, out string normalizedScope)
    {
        if (string.IsNullOrWhiteSpace(requestedScopes))
        {
            normalizedScope = McpTokenSecurity.ReadWriteScope;
            return true;
        }

        // Support space-separated or plus-separated scopes (e.g. "read read+write" or "read")
        var parts = requestedScopes.Split([' ', ',', '+'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        var hasWrite = parts.Contains("write", StringComparer.OrdinalIgnoreCase)
            || parts.Contains("read+write", StringComparer.OrdinalIgnoreCase);
        var hasRead = parts.Contains("read", StringComparer.OrdinalIgnoreCase)
            || parts.Contains("read+write", StringComparer.OrdinalIgnoreCase);

        if (!hasRead && !hasWrite)
        {
            normalizedScope = string.Empty;
            return false;
        }

        normalizedScope = hasWrite ? McpTokenSecurity.ReadWriteScope : McpTokenSecurity.ReadScope;
        return true;
    }
}
