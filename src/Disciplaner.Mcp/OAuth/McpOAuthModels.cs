using System.Text.Json.Serialization;

namespace Disciplaner.Mcp.OAuth;

/// <summary>
/// DTOs for standard OAuth 2.1 protocol endpoints (RFC 6749, RFC 7591, RFC 7636, RFC 8414, RFC 9728).
/// </summary>
public static class McpOAuthModels
{
    /// <summary>
    /// RFC 9728 Protected Resource Metadata.
    /// </summary>
    public sealed record ProtectedResourceMetadata(
        [property: JsonPropertyName("resource")] string Resource,
        [property: JsonPropertyName("authorization_servers")] IReadOnlyList<string> AuthorizationServers,
        [property: JsonPropertyName("scopes_supported")] IReadOnlyList<string> ScopesSupported,
        [property: JsonPropertyName("bearer_methods_supported")] IReadOnlyList<string> BearerMethodsSupported,
        [property: JsonPropertyName("documentation")] string? Documentation,
        [property: JsonPropertyName("resource_documentation")] string? ResourceDocumentation);

    /// <summary>
    /// RFC 8414 Authorization Server Metadata.
    /// </summary>
    public sealed record AuthorizationServerMetadata(
        [property: JsonPropertyName("issuer")] string Issuer,
        [property: JsonPropertyName("authorization_endpoint")] string AuthorizationEndpoint,
        [property: JsonPropertyName("token_endpoint")] string TokenEndpoint,
        [property: JsonPropertyName("registration_endpoint")] string RegistrationEndpoint,
        [property: JsonPropertyName("revocation_endpoint")] string RevocationEndpoint,
        [property: JsonPropertyName("response_types_supported")] IReadOnlyList<string> ResponseTypesSupported,
        [property: JsonPropertyName("grant_types_supported")] IReadOnlyList<string> GrantTypesSupported,
        [property: JsonPropertyName("token_endpoint_auth_methods_supported")] IReadOnlyList<string> TokenEndpointAuthMethodsSupported,
        [property: JsonPropertyName("code_challenge_methods_supported")] IReadOnlyList<string> CodeChallengeMethodsSupported,
        [property: JsonPropertyName("scopes_supported")] IReadOnlyList<string> ScopesSupported);

    /// <summary>
    /// RFC 7591 Dynamic Client Registration request.
    /// </summary>
    public sealed record ClientRegistrationRequest(
        [property: JsonPropertyName("client_name")] string? ClientName,
        [property: JsonPropertyName("redirect_uris")] IReadOnlyList<string>? RedirectUris,
        [property: JsonPropertyName("grant_types")] IReadOnlyList<string>? GrantTypes,
        [property: JsonPropertyName("response_types")] IReadOnlyList<string>? ResponseTypes,
        [property: JsonPropertyName("token_endpoint_auth_method")] string? TokenEndpointAuthMethod,
        [property: JsonPropertyName("scope")] string? Scope);

    /// <summary>
    /// RFC 7591 Dynamic Client Registration response.
    /// </summary>
    public sealed record ClientRegistrationResponse(
        [property: JsonPropertyName("client_id")] string ClientId,
        [property: JsonPropertyName("client_secret")] string? ClientSecret,
        [property: JsonPropertyName("client_name")] string ClientName,
        [property: JsonPropertyName("redirect_uris")] IReadOnlyList<string> RedirectUris,
        [property: JsonPropertyName("grant_types")] IReadOnlyList<string> GrantTypes,
        [property: JsonPropertyName("response_types")] IReadOnlyList<string> ResponseTypes,
        [property: JsonPropertyName("token_endpoint_auth_method")] string TokenEndpointAuthMethod,
        [property: JsonPropertyName("client_id_issued_at")] long ClientIdIssuedAt);

    /// <summary>
    /// RFC 6749 Token response.
    /// </summary>
    public sealed record TokenResponse(
        [property: JsonPropertyName("access_token")] string AccessToken,
        [property: JsonPropertyName("token_type")] string TokenType,
        [property: JsonPropertyName("expires_in")] int ExpiresIn,
        [property: JsonPropertyName("refresh_token")] string? RefreshToken,
        [property: JsonPropertyName("scope")] string Scope);

    /// <summary>
    /// RFC 6749 OAuth Error response.
    /// </summary>
    public sealed record OAuthErrorResponse(
        [property: JsonPropertyName("error")] string Error,
        [property: JsonPropertyName("error_description")] string? ErrorDescription);

    /// <summary>
    /// User authorization listing for management API.
    /// </summary>
    public sealed record OAuthAuthorizationDto(
        Guid Id,
        string ClientId,
        string ClientName,
        string Scope,
        DateTime CreatedAt,
        DateTime AccessTokenExpiresAt,
        DateTime? LastUsedAt,
        DateTime? RevokedAt);
}
