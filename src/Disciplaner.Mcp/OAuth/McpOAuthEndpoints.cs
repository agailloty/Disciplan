using System.Net;
using System.Security.Claims;
using System.Text;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Common;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Disciplaner.Mcp.OAuth;

public static class McpOAuthEndpoints
{
    public const string ProtectedResourcePath = "/.well-known/oauth-protected-resource";
    public const string AuthorizationServerPath = "/.well-known/oauth-authorization-server";
    public const string OpenIdConfigurationPath = "/.well-known/openid-configuration";
    public const string RegisterPath = "/oauth/register";
    public const string AuthorizePath = "/oauth/authorize";
    public const string TokenPath = "/oauth/token";
    public const string RevokePath = "/oauth/revoke";

    public static IEndpointRouteBuilder MapMcpOAuth(this IEndpointRouteBuilder app)
    {
        // ── 1. RFC 9728 Protected Resource Metadata ─────────────────────────────
        app.MapGet(ProtectedResourcePath, (HttpRequest request, IOptions<McpOptions> options) =>
        {
            var baseUrl = GetBaseUrl(request);
            var metadata = new McpOAuthModels.ProtectedResourceMetadata(
                Resource: baseUrl,
                AuthorizationServers: [baseUrl],
                ScopesSupported: [McpTokenSecurity.ReadScope, McpTokenSecurity.ReadWriteScope],
                BearerMethodsSupported: ["header"],
                Documentation: options.Value.PatDocumentationUrl,
                ResourceDocumentation: options.Value.PatDocumentationUrl);

            return Results.Ok(metadata);
        });

        // ── 2. RFC 8414 Authorization Server Metadata ───────────────────────────
        var handleServerMetadata = (HttpRequest request) =>
        {
            var baseUrl = GetBaseUrl(request);
            var metadata = new McpOAuthModels.AuthorizationServerMetadata(
                Issuer: baseUrl,
                AuthorizationEndpoint: $"{baseUrl}{AuthorizePath}",
                TokenEndpoint: $"{baseUrl}{TokenPath}",
                RegistrationEndpoint: $"{baseUrl}{RegisterPath}",
                RevocationEndpoint: $"{baseUrl}{RevokePath}",
                ResponseTypesSupported: ["code"],
                GrantTypesSupported: ["authorization_code", "refresh_token"],
                TokenEndpointAuthMethodsSupported: ["none", "client_secret_post", "client_secret_basic"],
                CodeChallengeMethodsSupported: [McpOAuthSecurity.PkceMethodS256],
                ScopesSupported: [McpTokenSecurity.ReadScope, McpTokenSecurity.ReadWriteScope]);

            return Results.Ok(metadata);
        };

        app.MapGet(AuthorizationServerPath, handleServerMetadata);
        app.MapGet(OpenIdConfigurationPath, handleServerMetadata);

        // ── 3. RFC 7591 Dynamic Client Registration ──────────────────────────────
        app.MapPost(RegisterPath, async (HttpRequest request, McpOAuthService oauth, CancellationToken ct) =>
        {
            var body = await request.ReadFromJsonAsync<McpOAuthModels.ClientRegistrationRequest>(cancellationToken: ct);
            if (body is null)
                return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse("invalid_request", "Missing request body."));

            var (response, error) = await oauth.RegisterClientAsync(body, ct);
            if (error != null)
                return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse("invalid_client_metadata", error));

            return Results.Json(response, statusCode: StatusCodes.Status201Created);
        });

        // ── 4. RFC 6749 Authorization Endpoint (GET) ─────────────────────────────
        app.MapGet(AuthorizePath, async (
            HttpRequest request,
            McpOAuthService oauth,
            CancellationToken ct) =>
        {
            var clientId = request.Query["client_id"].ToString();
            var redirectUri = request.Query["redirect_uri"].ToString();
            var responseType = request.Query["response_type"].ToString();
            var codeChallenge = request.Query["code_challenge"].ToString();
            var codeChallengeMethod = request.Query["code_challenge_method"].ToString();
            var scope = request.Query["scope"].ToString();
            var state = request.Query["state"].ToString();

            var (client, normalizedScope, error, errorDesc) = await oauth.ValidateAuthorizeRequestAsync(
                clientId, redirectUri, responseType, codeChallenge, codeChallengeMethod, scope, ct);

            if (error != null)
            {
                if (client != null && !string.IsNullOrWhiteSpace(redirectUri) && client.HasRedirectUri(redirectUri))
                {
                    var redirect = BuildRedirectUrl(redirectUri, [
                        ("error", error),
                        ("error_description", errorDesc ?? error),
                        ("state", state)
                    ]);
                    return Results.Redirect(redirect);
                }

                return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse(error, errorDesc));
            }

            var userEmail = request.HttpContext.User.Identity?.IsAuthenticated == true
                ? request.HttpContext.User.FindFirstValue(ClaimTypes.Email) ?? request.HttpContext.User.Identity.Name
                : null;

            var html = McpOAuthConsentPage.Render(
                clientName: client!.ClientName,
                scope: normalizedScope!,
                redirectUri: redirectUri,
                state: state,
                clientId: client.ClientId,
                codeChallenge: codeChallenge,
                codeChallengeMethod: string.IsNullOrWhiteSpace(codeChallengeMethod) ? "S256" : codeChallengeMethod,
                currentUserEmail: userEmail);

            return Results.Content(html, "text/html; charset=utf-8", Encoding.UTF8);
        });

        // ── 5. RFC 6749 Authorization Endpoint (POST) ────────────────────────────
        app.MapPost(AuthorizePath, async (
            HttpRequest request,
            McpOAuthService oauth,
            IServiceProvider sp,
            CancellationToken ct) =>
        {
            var form = await request.ReadFormAsync(ct);
            var clientId = form["client_id"].ToString();
            var redirectUri = form["redirect_uri"].ToString();
            var scope = form["scope"].ToString();
            var state = form["state"].ToString();
            var codeChallenge = form["code_challenge"].ToString();
            var codeChallengeMethod = form["code_challenge_method"].ToString();
            var action = form["action"].ToString();
            var email = form["email"].ToString();
            var password = form["password"].ToString();

            var (client, normalizedScope, error, errorDesc) = await oauth.ValidateAuthorizeRequestAsync(
                clientId, redirectUri, "code", codeChallenge, codeChallengeMethod, scope, ct);

            if (error != null)
            {
                if (client != null && !string.IsNullOrWhiteSpace(redirectUri) && client.HasRedirectUri(redirectUri))
                {
                    return Results.Redirect(BuildRedirectUrl(redirectUri, [
                        ("error", error),
                        ("error_description", errorDesc ?? error),
                        ("state", state)
                    ]));
                }
                return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse(error, errorDesc));
            }

            if (string.Equals(action, "deny", StringComparison.OrdinalIgnoreCase))
            {
                return Results.Redirect(BuildRedirectUrl(redirectUri, [
                    ("error", "access_denied"),
                    ("error_description", "The user denied the authorization request."),
                    ("state", state)
                ]));
            }

            string? userId = null;
            if (request.HttpContext.User.Identity?.IsAuthenticated == true)
            {
                userId = request.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? request.HttpContext.User.FindFirstValue("sub");
            }

            if (string.IsNullOrEmpty(userId))
            {
                if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                {
                    var html = McpOAuthConsentPage.Render(
                        clientName: client!.ClientName,
                        scope: normalizedScope!,
                        redirectUri: redirectUri,
                        state: state,
                        clientId: client.ClientId,
                        codeChallenge: codeChallenge,
                        codeChallengeMethod: codeChallengeMethod,
                        errorMessage: "Veuillez saisir votre adresse e-mail et mot de passe.");
                    return Results.Content(html, "text/html; charset=utf-8", Encoding.UTF8);
                }

                var authService = sp.GetRequiredService<IUserAuthenticationService>();
                var (success, validUserId, authError) = await authService.ValidateCredentialsAsync(email, password, ct);
                if (!success || string.IsNullOrEmpty(validUserId))
                {
                    var html = McpOAuthConsentPage.Render(
                        clientName: client!.ClientName,
                        scope: normalizedScope!,
                        redirectUri: redirectUri,
                        state: state,
                        clientId: client.ClientId,
                        codeChallenge: codeChallenge,
                        codeChallengeMethod: codeChallengeMethod,
                        errorMessage: "Identifiants invalides ou compte inactif.");
                    return Results.Content(html, "text/html; charset=utf-8", Encoding.UTF8);
                }

                userId = validUserId;
            }

            var authCode = await oauth.CreateAuthorizationCodeAsync(
                clientId: client!.ClientId,
                userId: userId!,
                redirectUri: redirectUri,
                scope: normalizedScope!,
                codeChallenge: codeChallenge,
                codeChallengeMethod: string.IsNullOrWhiteSpace(codeChallengeMethod) ? "S256" : codeChallengeMethod,
                ct: ct);

            return Results.Redirect(BuildRedirectUrl(redirectUri, [
                ("code", authCode),
                ("state", state)
            ]));
        });

        // ── 6. RFC 6749 Token Endpoint (POST) ────────────────────────────────────
        app.MapPost(TokenPath, async (HttpRequest request, McpOAuthService oauth, CancellationToken ct) =>
        {
            string? grantType = null;
            string? clientId = null;
            string? clientSecret = null;
            string? code = null;
            string? redirectUri = null;
            string? codeVerifier = null;
            string? refreshToken = null;
            string? scope = null;

            // Extract HTTP Basic authentication if present
            var authHeader = request.Headers.Authorization.ToString();
            if (authHeader.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    var creds = Encoding.UTF8.GetString(Convert.FromBase64String(authHeader["Basic ".Length..].Trim())).Split(':', 2);
                    if (creds.Length == 2)
                    {
                        clientId = creds[0];
                        clientSecret = creds[1];
                    }
                }
                catch
                {
                    return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse("invalid_client", "Malformed Basic credentials."));
                }
            }

            if (request.HasFormContentType)
            {
                var form = await request.ReadFormAsync(ct);
                grantType = form["grant_type"].ToString();
                clientId ??= form["client_id"].ToString();
                clientSecret ??= form["client_secret"].ToString();
                code = form["code"].ToString();
                redirectUri = form["redirect_uri"].ToString();
                codeVerifier = form["code_verifier"].ToString();
                refreshToken = form["refresh_token"].ToString();
                scope = form["scope"].ToString();
            }
            else
            {
                try
                {
                    using var doc = await System.Text.Json.JsonDocument.ParseAsync(request.Body, cancellationToken: ct);
                    var root = doc.RootElement;
                    if (root.TryGetProperty("grant_type", out var g)) grantType = g.GetString();
                    if (root.TryGetProperty("client_id", out var c)) clientId ??= c.GetString();
                    if (root.TryGetProperty("client_secret", out var s)) clientSecret ??= s.GetString();
                    if (root.TryGetProperty("code", out var cd)) code = cd.GetString();
                    if (root.TryGetProperty("redirect_uri", out var ru)) redirectUri = ru.GetString();
                    if (root.TryGetProperty("code_verifier", out var cv)) codeVerifier = cv.GetString();
                    if (root.TryGetProperty("refresh_token", out var rt)) refreshToken = rt.GetString();
                    if (root.TryGetProperty("scope", out var sc)) scope = sc.GetString();
                }
                catch
                {
                    return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse("invalid_request", "Unable to parse request body."));
                }
            }

            if (string.Equals(grantType, "authorization_code", StringComparison.Ordinal))
            {
                var (response, error, errorDesc) = await oauth.ExchangeAuthorizationCodeAsync(
                    clientId, clientSecret, code, redirectUri, codeVerifier, ct);

                if (error != null)
                    return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse(error, errorDesc));

                return Results.Ok(response);
            }

            if (string.Equals(grantType, "refresh_token", StringComparison.Ordinal))
            {
                var (response, error, errorDesc) = await oauth.RefreshTokenAsync(
                    clientId, clientSecret, refreshToken, scope, ct);

                if (error != null)
                    return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse(error, errorDesc));

                return Results.Ok(response);
            }

            return Results.BadRequest(new McpOAuthModels.OAuthErrorResponse(
                "unsupported_grant_type",
                $"Grant type '{grantType}' is not supported. Supported: 'authorization_code', 'refresh_token'."));
        });

        // ── 7. RFC 7009 Token Revocation Endpoint (POST) ─────────────────────────
        app.MapPost(RevokePath, async (HttpRequest request, McpOAuthService oauth, CancellationToken ct) =>
        {
            string? token = null;
            string? tokenTypeHint = null;
            string? clientId = null;
            string? clientSecret = null;

            var authHeader = request.Headers.Authorization.ToString();
            if (authHeader.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    var creds = Encoding.UTF8.GetString(Convert.FromBase64String(authHeader["Basic ".Length..].Trim())).Split(':', 2);
                    if (creds.Length == 2)
                    {
                        clientId = creds[0];
                        clientSecret = creds[1];
                    }
                }
                catch { }
            }

            if (request.HasFormContentType)
            {
                var form = await request.ReadFormAsync(ct);
                token = form["token"].ToString();
                tokenTypeHint = form["token_type_hint"].ToString();
                clientId ??= form["client_id"].ToString();
                clientSecret ??= form["client_secret"].ToString();
            }
            else
            {
                try
                {
                    using var doc = await System.Text.Json.JsonDocument.ParseAsync(request.Body, cancellationToken: ct);
                    var root = doc.RootElement;
                    if (root.TryGetProperty("token", out var t)) token = t.GetString();
                    if (root.TryGetProperty("token_type_hint", out var th)) tokenTypeHint = th.GetString();
                    if (root.TryGetProperty("client_id", out var c)) clientId ??= c.GetString();
                    if (root.TryGetProperty("client_secret", out var s)) clientSecret ??= s.GetString();
                }
                catch { }
            }

            await oauth.RevokeTokenAsync(clientId, clientSecret, token, tokenTypeHint, ct);
            return Results.Ok();
        });

        return app;
    }

    private static string GetBaseUrl(HttpRequest request) =>
        $"{request.Scheme}://{request.Host}";

    private static string BuildRedirectUrl(string redirectUri, IEnumerable<(string Key, string? Value)> queryParams)
    {
        var sb = new StringBuilder(redirectUri);
        var hasQuery = redirectUri.Contains('?');

        foreach (var (key, value) in queryParams)
        {
            if (string.IsNullOrEmpty(value))
                continue;

            sb.Append(hasQuery ? '&' : '?');
            hasQuery = true;
            sb.Append(Uri.EscapeDataString(key));
            sb.Append('=');
            sb.Append(Uri.EscapeDataString(value));
        }

        return sb.ToString();
    }
}
