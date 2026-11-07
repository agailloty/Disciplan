using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace Disciplaner.Mcp.OAuth;

public sealed class McpOAuthService
{
    public const int DefaultAccessTokenLifetimeSeconds = 3600; // 1 hour
    public static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(30);
    public static readonly TimeSpan AuthorizationCodeLifetime = TimeSpan.FromMinutes(5);

    private readonly IUnitOfWork _uow;
    private readonly ILogger<McpOAuthService> _logger;

    public McpOAuthService(IUnitOfWork uow, ILogger<McpOAuthService> logger)
    {
        _uow = uow;
        _logger = logger;
    }

    /// <summary>
    /// Registers a new OAuth 2.1 client application dynamically (RFC 7591).
    /// </summary>
    public async Task<(McpOAuthModels.ClientRegistrationResponse? Response, string? Error)> RegisterClientAsync(
        McpOAuthModels.ClientRegistrationRequest request,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(request.ClientName))
            return (null, "client_name is required.");

        if (request.RedirectUris is null || request.RedirectUris.Count == 0)
            return (null, "At least one redirect_uri is required.");

        foreach (var uri in request.RedirectUris)
        {
            if (string.IsNullOrWhiteSpace(uri) || !Uri.TryCreate(uri, UriKind.Absolute, out var parsed) || !string.IsNullOrEmpty(parsed.Fragment))
                return (null, $"Invalid redirect_uri: '{uri}'. Must be an absolute URI without fragment.");
        }

        var authMethod = string.Equals(request.TokenEndpointAuthMethod, "client_secret_post", StringComparison.OrdinalIgnoreCase)
            || string.Equals(request.TokenEndpointAuthMethod, "client_secret_basic", StringComparison.OrdinalIgnoreCase)
            ? "client_secret_post"
            : "none";

        var clientId = McpOAuthSecurity.GenerateClientId();
        string? rawSecret = null;
        string? secretHash = null;

        if (authMethod != "none")
        {
            rawSecret = McpOAuthSecurity.GenerateClientSecret();
            secretHash = McpOAuthSecurity.Sha256(rawSecret);
        }

        var client = new McpOAuthClient(
            clientId: clientId,
            clientName: request.ClientName.Trim(),
            redirectUris: request.RedirectUris,
            clientSecretHash: secretHash,
            tokenEndpointAuthMethod: authMethod);

        await _uow.McpOAuth.AddClientAsync(client, ct);
        await _uow.SaveChangesAsync(ct);

        var response = new McpOAuthModels.ClientRegistrationResponse(
            ClientId: client.ClientId,
            ClientSecret: rawSecret,
            ClientName: client.ClientName,
            RedirectUris: client.GetRedirectUris(),
            GrantTypes: ["authorization_code", "refresh_token"],
            ResponseTypes: ["code"],
            TokenEndpointAuthMethod: authMethod,
            ClientIdIssuedAt: DateTimeOffset.UtcNow.ToUnixTimeSeconds());

        return (response, null);
    }

    /// <summary>
    /// Validates an incoming authorization request according to RFC 6749 and PKCE (RFC 7636).
    /// </summary>
    public async Task<(McpOAuthClient? Client, string? NormalizedScope, string? Error, string? ErrorDescription)> ValidateAuthorizeRequestAsync(
        string? clientId,
        string? redirectUri,
        string? responseType,
        string? codeChallenge,
        string? codeChallengeMethod,
        string? scope,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(clientId))
            return (null, null, "invalid_request", "Missing client_id parameter.");

        var client = await _uow.McpOAuth.GetClientByIdAsync(clientId, ct);
        if (client is null)
            return (null, null, "invalid_client", "Unknown client_id.");

        if (string.IsNullOrWhiteSpace(redirectUri))
            return (client, null, "invalid_request", "Missing redirect_uri parameter.");

        if (!client.HasRedirectUri(redirectUri))
            return (client, null, "invalid_request", "The specified redirect_uri is not registered for this client.");

        if (!string.Equals(responseType, "code", StringComparison.Ordinal))
            return (client, null, "unsupported_response_type", "Only response_type 'code' is supported.");

        // PKCE is required for OAuth 2.1
        if (string.IsNullOrWhiteSpace(codeChallenge))
            return (client, null, "invalid_request", "Missing code_challenge parameter (PKCE is required).");

        var method = string.IsNullOrWhiteSpace(codeChallengeMethod) ? McpOAuthSecurity.PkceMethodS256 : codeChallengeMethod;
        if (!string.Equals(method, McpOAuthSecurity.PkceMethodS256, StringComparison.OrdinalIgnoreCase))
            return (client, null, "invalid_request", "Only code_challenge_method 'S256' is supported.");

        if (!McpOAuthSecurity.TryNormalizeScopes(scope, out var normalizedScope))
            return (client, null, "invalid_scope", "Requested scope is invalid. Supported scopes: 'read', 'read+write'.");

        return (client, normalizedScope, null, null);
    }

    /// <summary>
    /// Issues a short-lived authorization code bound to the PKCE challenge.
    /// </summary>
    public async Task<string> CreateAuthorizationCodeAsync(
        string clientId,
        string userId,
        string redirectUri,
        string scope,
        string codeChallenge,
        string codeChallengeMethod,
        CancellationToken ct = default)
    {
        var rawCode = McpOAuthSecurity.GenerateAuthorizationCode();
        var codeHash = McpOAuthSecurity.Sha256(rawCode);
        var expiresAt = DateTime.UtcNow.Add(AuthorizationCodeLifetime);

        var authCode = new McpOAuthAuthorizationCode(
            codeHash: codeHash,
            clientId: clientId,
            userId: userId,
            redirectUri: redirectUri,
            scope: scope,
            codeChallenge: codeChallenge,
            codeChallengeMethod: codeChallengeMethod,
            expiresAt: expiresAt);

        await _uow.McpOAuth.AddCodeAsync(authCode, ct);
        await _uow.SaveChangesAsync(ct);

        return rawCode;
    }

    /// <summary>
    /// Exchanges an authorization code and PKCE verifier for an access and refresh token pair (RFC 6749 Section 4.1.3).
    /// </summary>
    public async Task<(McpOAuthModels.TokenResponse? Response, string? Error, string? ErrorDescription)> ExchangeAuthorizationCodeAsync(
        string? clientId,
        string? clientSecret,
        string? code,
        string? redirectUri,
        string? codeVerifier,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(redirectUri) || string.IsNullOrWhiteSpace(codeVerifier))
            return (null, "invalid_request", "Missing required parameters (client_id, code, redirect_uri, code_verifier).");

        var client = await _uow.McpOAuth.GetClientByIdAsync(clientId, ct);
        if (client is null)
            return (null, "invalid_client", "Unknown client_id.");

        if (!client.VerifySecret(clientSecret))
            return (null, "invalid_client", "Invalid client secret.");

        var codeHash = McpOAuthSecurity.Sha256(code);
        var authCode = await _uow.McpOAuth.GetCodeByHashAsync(codeHash, ct);
        var now = DateTime.UtcNow;

        if (authCode is null || !authCode.IsActive(now))
            return (null, "invalid_grant", "Authorization code is invalid, expired, or already used.");

        if (!string.Equals(authCode.ClientId, clientId, StringComparison.Ordinal))
            return (null, "invalid_grant", "Client identifier mismatch.");

        if (!string.Equals(authCode.RedirectUri, redirectUri, StringComparison.Ordinal))
            return (null, "invalid_grant", "Redirect URI mismatch.");

        if (!McpOAuthSecurity.VerifyPkce(codeVerifier, authCode.CodeChallenge, authCode.CodeChallengeMethod))
            return (null, "invalid_grant", "PKCE verification failed.");

        // Invalidate authorization code immediately to prevent replay
        authCode.MarkUsed(now);

        var rawAccessToken = McpOAuthSecurity.GenerateAccessToken();
        var rawRefreshToken = McpOAuthSecurity.GenerateRefreshToken();

        var accessHash = McpOAuthSecurity.Sha256(rawAccessToken);
        var refreshHash = McpOAuthSecurity.Sha256(rawRefreshToken);

        var accessExpiresAt = now.AddSeconds(DefaultAccessTokenLifetimeSeconds);
        var refreshExpiresAt = now.Add(RefreshTokenLifetime);

        var token = new McpOAuthToken(
            clientId: clientId,
            userId: authCode.UserId,
            scope: authCode.Scope,
            accessTokenHash: accessHash,
            accessTokenExpiresAt: accessExpiresAt,
            refreshTokenHash: refreshHash,
            refreshTokenExpiresAt: refreshExpiresAt);

        await _uow.McpOAuth.AddTokenAsync(token, ct);
        await _uow.SaveChangesAsync(ct);

        var response = new McpOAuthModels.TokenResponse(
            AccessToken: rawAccessToken,
            TokenType: "Bearer",
            ExpiresIn: DefaultAccessTokenLifetimeSeconds,
            RefreshToken: rawRefreshToken,
            Scope: token.Scope);

        return (response, null, null);
    }

    /// <summary>
    /// Refreshes an access token using a valid refresh token (RFC 6749 Section 6).
    /// </summary>
    public async Task<(McpOAuthModels.TokenResponse? Response, string? Error, string? ErrorDescription)> RefreshTokenAsync(
        string? clientId,
        string? clientSecret,
        string? refreshToken,
        string? requestedScope,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(refreshToken))
            return (null, "invalid_request", "Missing required parameters (client_id, refresh_token).");

        var client = await _uow.McpOAuth.GetClientByIdAsync(clientId, ct);
        if (client is null)
            return (null, "invalid_client", "Unknown client_id.");

        if (!client.VerifySecret(clientSecret))
            return (null, "invalid_client", "Invalid client secret.");

        var refreshHash = McpOAuthSecurity.Sha256(refreshToken);
        var token = await _uow.McpOAuth.GetTokenByRefreshHashAsync(refreshHash, ct);
        var now = DateTime.UtcNow;

        if (token is null || !token.IsRefreshTokenActive(now))
            return (null, "invalid_grant", "Refresh token is invalid, expired, or revoked.");

        if (!string.Equals(token.ClientId, clientId, StringComparison.Ordinal))
            return (null, "invalid_grant", "Client identifier mismatch.");

        var scope = token.Scope;
        if (!string.IsNullOrWhiteSpace(requestedScope))
        {
            if (!McpOAuthSecurity.TryNormalizeScopes(requestedScope, out var normalizedScope))
                return (null, "invalid_scope", "Requested scope is invalid.");

            // Scope can only be narrowed, not broadened
            if (token.Scope == McpTokenSecurity.ReadScope && normalizedScope == McpTokenSecurity.ReadWriteScope)
                return (null, "invalid_scope", "Cannot expand scope on token refresh.");

            scope = normalizedScope;
        }

        var newAccessToken = McpOAuthSecurity.GenerateAccessToken();
        var newRefreshToken = McpOAuthSecurity.GenerateRefreshToken();

        var newAccessHash = McpOAuthSecurity.Sha256(newAccessToken);
        var newRefreshHash = McpOAuthSecurity.Sha256(newRefreshToken);

        var accessExpiresAt = now.AddSeconds(DefaultAccessTokenLifetimeSeconds);
        var refreshExpiresAt = now.Add(RefreshTokenLifetime);

        token.RotateTokens(newAccessHash, accessExpiresAt, newRefreshHash, refreshExpiresAt);
        await _uow.McpOAuth.UpdateTokenAsync(token, ct);
        await _uow.SaveChangesAsync(ct);

        var response = new McpOAuthModels.TokenResponse(
            AccessToken: newAccessToken,
            TokenType: "Bearer",
            ExpiresIn: DefaultAccessTokenLifetimeSeconds,
            RefreshToken: newRefreshToken,
            Scope: scope);

        return (response, null, null);
    }

    /// <summary>
    /// Revokes an access or refresh token (RFC 7009).
    /// </summary>
    public async Task RevokeTokenAsync(
        string? clientId,
        string? clientSecret,
        string? tokenValue,
        string? tokenTypeHint,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(tokenValue))
            return;

        // If client credentials provided, verify client
        if (!string.IsNullOrWhiteSpace(clientId))
        {
            var client = await _uow.McpOAuth.GetClientByIdAsync(clientId, ct);
            if (client is not null && !client.VerifySecret(clientSecret))
                return;
        }

        var hash = McpOAuthSecurity.Sha256(tokenValue);
        var token = await _uow.McpOAuth.GetTokenByAccessHashAsync(hash, ct)
            ?? await _uow.McpOAuth.GetTokenByRefreshHashAsync(hash, ct);

        if (token != null)
        {
            token.Revoke(DateTime.UtcNow);
            await _uow.McpOAuth.UpdateTokenAsync(token, ct);
            await _uow.SaveChangesAsync(ct);
        }
    }

    /// <summary>
    /// Lists active OAuth authorizations for a specific user.
    /// </summary>
    public async Task<IReadOnlyList<McpOAuthModels.OAuthAuthorizationDto>> ListUserAuthorizationsAsync(string userId, CancellationToken ct = default)
    {
        var tokens = await _uow.McpOAuth.GetTokensByUserIdAsync(userId, ct);
        var result = new List<McpOAuthModels.OAuthAuthorizationDto>(tokens.Count);

        foreach (var token in tokens)
        {
            var client = await _uow.McpOAuth.GetClientByIdAsync(token.ClientId, ct);
            result.Add(new McpOAuthModels.OAuthAuthorizationDto(
                Id: token.Id,
                ClientId: token.ClientId,
                ClientName: client?.ClientName ?? token.ClientId,
                Scope: token.Scope,
                CreatedAt: token.CreatedAt,
                AccessTokenExpiresAt: token.AccessTokenExpiresAt,
                LastUsedAt: token.LastUsedAt,
                RevokedAt: token.RevokedAt));
        }

        return result;
    }

    /// <summary>
    /// Revokes an authorization owned by a user.
    /// </summary>
    public async Task<bool> RevokeUserAuthorizationAsync(string userId, Guid tokenId, CancellationToken ct = default)
    {
        var token = await _uow.McpOAuth.GetTokenByIdAsync(tokenId, userId, ct);
        if (token is null)
            return false;

        token.Revoke(DateTime.UtcNow);
        await _uow.McpOAuth.UpdateTokenAsync(token, ct);
        await _uow.SaveChangesAsync(ct);
        return true;
    }
}
