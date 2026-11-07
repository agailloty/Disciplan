using System.Security.Cryptography;
using System.Text.Json;
using Disciplaner.Domain.Common;

namespace Disciplaner.Domain.Entities;

/// <summary>
/// Registered OAuth 2.1 client (RFC 7591 Dynamic Client Registration or pre-configured).
/// Represents an external MCP client application like Claude Desktop, Cursor, ChatGPT, etc.
/// </summary>
public sealed class McpOAuthClient
{
    public Guid Id { get; private init; }

    /// <summary>Unique client identifier (e.g. dcp_client_...).</summary>
    public string ClientId { get; private init; } = string.Empty;

    /// <summary>Display name of the client application (e.g. "Claude Desktop").</summary>
    public string ClientName { get; private init; } = string.Empty;

    /// <summary>Optional SHA-256 hash of client secret for confidential clients (null for public PKCE clients).</summary>
    public string? ClientSecretHash { get; private set; }

    /// <summary>JSON array of permitted redirection URIs.</summary>
    public string RedirectUrisJson { get; private set; } = "[]";

    /// <summary>JSON array of permitted grant types (e.g. ["authorization_code", "refresh_token"]).</summary>
    public string GrantTypesJson { get; private set; } = "[\"authorization_code\",\"refresh_token\"]";

    /// <summary>JSON array of permitted response types (e.g. ["code"]).</summary>
    public string ResponseTypesJson { get; private set; } = "[\"code\"]";

    /// <summary>Authentication method at the token endpoint ("none" for public, "client_secret_post" for confidential).</summary>
    public string TokenEndpointAuthMethod { get; private set; } = "none";

    public DateTime CreatedAt { get; private init; }

    // Required by EF Core
    private McpOAuthClient() { }

    public McpOAuthClient(
        string clientId,
        string clientName,
        IEnumerable<string> redirectUris,
        string? clientSecretHash = null,
        string tokenEndpointAuthMethod = "none")
    {
        if (string.IsNullOrWhiteSpace(clientId))
            throw new ArgumentException("ClientId is required.", nameof(clientId));
        if (string.IsNullOrWhiteSpace(clientName))
            throw new ArgumentException("ClientName is required.", nameof(clientName));

        var uris = redirectUris?.Where(u => !string.IsNullOrWhiteSpace(u)).Select(u => u.Trim()).ToList()
            ?? throw new ArgumentException("At least one valid redirect URI is required.", nameof(redirectUris));
        if (uris.Count == 0)
            throw new ArgumentException("At least one valid redirect URI is required.", nameof(redirectUris));

        Id = Guid.NewGuid();
        ClientId = clientId.Trim();
        ClientName = clientName.Trim();
        ClientSecretHash = string.IsNullOrWhiteSpace(clientSecretHash) ? null : clientSecretHash;
        TokenEndpointAuthMethod = string.IsNullOrWhiteSpace(tokenEndpointAuthMethod) ? "none" : tokenEndpointAuthMethod.Trim();
        RedirectUrisJson = JsonSerializer.Serialize(uris);
        CreatedAt = DateTime.UtcNow;
    }

    public IReadOnlyList<string> GetRedirectUris()
    {
        try
        {
            return JsonSerializer.Deserialize<List<string>>(RedirectUrisJson) ?? [];
        }
        catch
        {
            return [];
        }
    }

    public bool HasRedirectUri(string redirectUri)
    {
        if (string.IsNullOrWhiteSpace(redirectUri))
            return false;

        var uris = GetRedirectUris();
        return uris.Any(u => string.Equals(u, redirectUri.Trim(), StringComparison.Ordinal));
    }

    public bool VerifySecret(string? rawSecret)
    {
        if (string.IsNullOrEmpty(ClientSecretHash))
            return true; // Public client, no secret required

        if (string.IsNullOrEmpty(rawSecret))
            return false;

        var computedHash = McpOAuthSecurity.Sha256(rawSecret);
        return CryptographicOperations.FixedTimeEquals(
            System.Text.Encoding.UTF8.GetBytes(computedHash),
            System.Text.Encoding.UTF8.GetBytes(ClientSecretHash));
    }
}
