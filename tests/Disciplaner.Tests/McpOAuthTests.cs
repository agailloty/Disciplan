using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Disciplaner.Mcp.McpAuth;
using Disciplaner.Mcp.OAuth;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Comprehensive integration tests for MCP OAuth 2.1 authentication:
/// RFC 9728 (Protected Resource Metadata), RFC 8414 (Authorization Server Metadata),
/// RFC 7591 (Dynamic Client Registration), RFC 7636 (PKCE), RFC 6749 (Authorization & Token),
/// RFC 7009 (Revocation) and /mcp access token consumption.
/// </summary>
public class McpOAuthTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"mcp-oauth-tests","version":"1.0"}}}""";
    private const string ToolsListRequest =
        """{"jsonrpc":"2.0","id":2,"method":"tools/list"}""";

    private static HttpClient CreateClient(ApiFactory factory) =>
        factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            AllowAutoRedirect = false
        });

    private static async Task<HttpResponseMessage> PostRpcAsync(HttpClient client, string json, string? sessionId = null)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/mcp")
        {
            Content = new StringContent(json, Encoding.UTF8, "application/json")
        };
        request.Headers.Accept.ParseAdd("application/json");
        request.Headers.Accept.ParseAdd("text/event-stream");
        if (sessionId is not null)
            request.Headers.TryAddWithoutValidation("mcp-session-id", sessionId);
        return await client.SendAsync(request);
    }

    private static async Task<JsonElement> ReadRpcResultAsync(HttpResponseMessage response)
    {
        var body = await response.Content.ReadAsStringAsync();
        var contentType = response.Content.Headers.ContentType?.MediaType ?? "";
        if (contentType.Contains("text/event-stream"))
        {
            var data = body.Split('\n')
                .Where(line => line.StartsWith("data:", StringComparison.Ordinal))
                .Select(line => line["data:".Length..].Trim())
                .FirstOrDefault();
            body = data ?? body;
        }
        using var document = JsonDocument.Parse(body);
        return document.RootElement.Clone();
    }

    private static (string CodeVerifier, string CodeChallenge) GeneratePkce()
    {
        var verifier = McpOAuthSecurity.GenerateRandomUrlSafeString(32);
        var hash = SHA256.HashData(Encoding.ASCII.GetBytes(verifier));
        var challenge = Convert.ToBase64String(hash)
            .TrimEnd('=')
            .Replace('+', '-')
            .Replace('/', '_');
        return (verifier, challenge);
    }

    // ── 1. RFC 9728 & RFC 8414 Discovery ─────────────────────────────────────

    [Fact]
    public async Task Protected_resource_metadata_advertises_authorization_servers()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        using var response = await client.GetAsync("/.well-known/oauth-protected-resource");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var root = payload.RootElement;

        Assert.Equal("https://localhost", root.GetProperty("resource").GetString());
        var authServers = root.GetProperty("authorization_servers").EnumerateArray()
            .Select(s => s.GetString()).ToList();
        Assert.Contains("https://localhost", authServers);

        var scopes = root.GetProperty("scopes_supported").EnumerateArray()
            .Select(s => s.GetString()).ToList();
        Assert.Contains("read", scopes);
        Assert.Contains("read+write", scopes);
    }

    [Fact]
    public async Task Authorization_server_metadata_satisfies_rfc8414()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        foreach (var path in new[] { "/.well-known/oauth-authorization-server", "/.well-known/openid-configuration" })
        {
            using var response = await client.GetAsync(path);
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            var root = payload.RootElement;

            Assert.Equal("https://localhost", root.GetProperty("issuer").GetString());
            Assert.Equal("https://localhost/oauth/authorize", root.GetProperty("authorization_endpoint").GetString());
            Assert.Equal("https://localhost/oauth/token", root.GetProperty("token_endpoint").GetString());
            Assert.Equal("https://localhost/oauth/register", root.GetProperty("registration_endpoint").GetString());
            Assert.Equal("https://localhost/oauth/revoke", root.GetProperty("revocation_endpoint").GetString());

            var grants = root.GetProperty("grant_types_supported").EnumerateArray().Select(s => s.GetString()).ToList();
            Assert.Contains("authorization_code", grants);
            Assert.Contains("refresh_token", grants);

            var pkce = root.GetProperty("code_challenge_methods_supported").EnumerateArray().Select(s => s.GetString()).ToList();
            Assert.Contains("S256", pkce);
        }
    }

    [Fact]
    public async Task Public_base_url_setting_rewrites_discovery_and_challenge_urls()
    {
        // Behind a TLS-terminating proxy that does not forward X-Forwarded-Proto,
        // Mcp:PublicBaseUrl forces https discovery URLs (RFC 9728 §6.4 resource match).
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory
            .WithWebHostBuilder(b => b.UseSetting("Mcp:PublicBaseUrl", "https://mcp-public.example.com/"))
            .CreateClient(new WebApplicationFactoryClientOptions
            {
                BaseAddress = new Uri("https://localhost"),
                AllowAutoRedirect = false
            });

        using var metadata = await client.GetAsync("/.well-known/oauth-protected-resource");
        Assert.Equal(HttpStatusCode.OK, metadata.StatusCode);
        using var payload = JsonDocument.Parse(await metadata.Content.ReadAsStringAsync());
        Assert.Equal("https://mcp-public.example.com", payload.RootElement.GetProperty("resource").GetString());

        using var challenge = await PostRpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, challenge.StatusCode);
        Assert.Equal(
            "Bearer resource_metadata=\"https://mcp-public.example.com/.well-known/oauth-protected-resource\"",
            challenge.Headers.WwwAuthenticate.ToString());
    }

    // ── 2. RFC 7591 Dynamic Client Registration ──────────────────────────────

    [Fact]
    public async Task Dynamic_client_registration_creates_public_and_confidential_clients()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        // Public client (Claude Desktop / Cursor style)
        using var pubResponse = await client.PostAsJsonAsync("/oauth/register", new
        {
            client_name = "Claude Desktop",
            redirect_uris = new[] { "http://127.0.0.1:54321/callback" },
            token_endpoint_auth_method = "none"
        });
        Assert.Equal(HttpStatusCode.Created, pubResponse.StatusCode);

        using var pubDoc = JsonDocument.Parse(await pubResponse.Content.ReadAsStringAsync());
        var pubRoot = pubDoc.RootElement;
        var pubClientId = pubRoot.GetProperty("client_id").GetString();
        Assert.NotNull(pubClientId);
        Assert.StartsWith(McpOAuthSecurity.ClientIdPrefix, pubClientId);
        Assert.False(pubRoot.TryGetProperty("client_secret", out var s) && !string.IsNullOrEmpty(s.GetString()));
        Assert.Equal("Claude Desktop", pubRoot.GetProperty("client_name").GetString());

        // Confidential client
        using var confResponse = await client.PostAsJsonAsync("/oauth/register", new
        {
            client_name = "Backend Agent Service",
            redirect_uris = new[] { "https://agent.example.com/oauth/callback" },
            token_endpoint_auth_method = "client_secret_post"
        });
        Assert.Equal(HttpStatusCode.Created, confResponse.StatusCode);

        using var confDoc = JsonDocument.Parse(await confResponse.Content.ReadAsStringAsync());
        var confRoot = confDoc.RootElement;
        var secret = confRoot.GetProperty("client_secret").GetString();
        Assert.NotNull(secret);
        Assert.StartsWith(McpOAuthSecurity.ClientSecretPrefix, secret);
    }

    [Fact]
    public async Task Dynamic_client_registration_rejects_invalid_inputs()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        // Missing client_name
        using var noName = await client.PostAsJsonAsync("/oauth/register", new
        {
            redirect_uris = new[] { "https://example.com/callback" }
        });
        Assert.Equal(HttpStatusCode.BadRequest, noName.StatusCode);

        // Empty redirect_uris
        using var emptyUris = await client.PostAsJsonAsync("/oauth/register", new
        {
            client_name = "Test",
            redirect_uris = Array.Empty<string>()
        });
        Assert.Equal(HttpStatusCode.BadRequest, emptyUris.StatusCode);

        // Redirect URI with fragment
        using var fragmentUri = await client.PostAsJsonAsync("/oauth/register", new
        {
            client_name = "Test",
            redirect_uris = new[] { "https://example.com/callback#fragment" }
        });
        Assert.Equal(HttpStatusCode.BadRequest, fragmentUri.StatusCode);
    }

    // ── 3. Authorization Code & PKCE Flow ────────────────────────────────────

    [Fact]
    public async Task Full_oauth_authorization_flow_with_pkce_issues_tokens_and_enables_mcp()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        // 1. Register Client
        const string redirectUri = "http://127.0.0.1:8765/callback";
        var regResponse = await client.PostAsJsonAsync("/oauth/register", new
        {
            client_name = "Test Assistant",
            redirect_uris = new[] { redirectUri }
        });
        var regPayload = JsonDocument.Parse(await regResponse.Content.ReadAsStringAsync()).RootElement;
        var clientId = regPayload.GetProperty("client_id").GetString()!;

        // 2. PKCE setup
        var (codeVerifier, codeChallenge) = GeneratePkce();
        const string state = "test-state-xyz";

        // 3. GET /oauth/authorize -> renders consent HTML
        var authorizeUrl = $"/oauth/authorize?response_type=code&client_id={clientId}&redirect_uri={Uri.EscapeDataString(redirectUri)}&code_challenge={codeChallenge}&code_challenge_method=S256&scope=read%2Bwrite&state={state}";
        var getAuthResponse = await client.GetAsync(authorizeUrl);
        Assert.Equal(HttpStatusCode.OK, getAuthResponse.StatusCode);
        var html = await getAuthResponse.Content.ReadAsStringAsync();
        Assert.Contains("Test Assistant", html);
        Assert.Contains("Disciplaner", html);

        // 4. POST /oauth/authorize -> user signs in and approves
        // User credentials from BaselineFixture (member@example.invalid / Password123!)
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read+write",
            ["state"] = state,
            ["code_challenge"] = codeChallenge,
            ["code_challenge_method"] = "S256",
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };

        var postAuthResponse = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        Assert.Equal(HttpStatusCode.Redirect, postAuthResponse.StatusCode);
        var location = postAuthResponse.Headers.Location?.ToString();
        Assert.NotNull(location);
        Assert.StartsWith(redirectUri, location);
        Assert.Contains($"state={state}", location);

        var query = new Uri(location).Query;
        var parsedQuery = System.Web.HttpUtility.ParseQueryString(query);
        var authCode = parsedQuery["code"];
        Assert.NotNull(authCode);
        Assert.StartsWith(McpOAuthSecurity.AuthorizationCodePrefix, authCode);

        // 5. POST /oauth/token -> exchange code + PKCE verifier for tokens
        var tokenExchangeForm = new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = codeVerifier
        };

        var tokenResponse = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(tokenExchangeForm));
        Assert.Equal(HttpStatusCode.OK, tokenResponse.StatusCode);

        using var tokenDoc = JsonDocument.Parse(await tokenResponse.Content.ReadAsStringAsync());
        var tokenRoot = tokenDoc.RootElement;
        var accessToken = tokenRoot.GetProperty("access_token").GetString()!;
        var refreshToken = tokenRoot.GetProperty("refresh_token").GetString()!;
        var tokenType = tokenRoot.GetProperty("token_type").GetString();
        var scope = tokenRoot.GetProperty("scope").GetString();
        var expiresIn = tokenRoot.GetProperty("expires_in").GetInt32();

        Assert.NotNull(accessToken);
        Assert.StartsWith(McpOAuthSecurity.AccessTokenPrefix, accessToken);
        Assert.NotNull(refreshToken);
        Assert.StartsWith(McpOAuthSecurity.RefreshTokenPrefix, refreshToken);
        Assert.Equal("Bearer", tokenType);
        Assert.Equal("read+write", scope);
        Assert.True(expiresIn > 0);

        // 6. Use OAuth Access Token on /mcp
        using var mcpClient = CreateClient(factory);
        mcpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var initResponse = await PostRpcAsync(mcpClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, initResponse.StatusCode);

        var rpcResult = await ReadRpcResultAsync(initResponse);
        var resultPayload = rpcResult.GetProperty("result");
        Assert.True(resultPayload.TryGetProperty("serverInfo", out _));

        var sessionId = initResponse.Headers.TryGetValues("mcp-session-id", out var values)
            ? values.FirstOrDefault() : null;

        using var toolsResponse = await PostRpcAsync(mcpClient, ToolsListRequest, sessionId);
        Assert.Equal(HttpStatusCode.OK, toolsResponse.StatusCode);
        var toolsResult = await ReadRpcResultAsync(toolsResponse);
        var toolNames = toolsResult.GetProperty("result").GetProperty("tools").EnumerateArray()
            .Select(t => t.GetProperty("name").GetString()).ToList();

        Assert.Contains("ping", toolNames);
        Assert.Contains("list_projects", toolNames);
        Assert.Contains("create_ticket", toolNames); // read+write scope has write tools
    }

    [Fact]
    public async Task Token_exchange_with_invalid_pkce_verifier_is_rejected()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        const string redirectUri = "http://localhost:5000/callback";
        var reg = await client.PostAsJsonAsync("/oauth/register", new { client_name = "PKCE Test", redirect_uris = new[] { redirectUri } });
        var clientId = JsonDocument.Parse(await reg.Content.ReadAsStringAsync()).RootElement.GetProperty("client_id").GetString()!;

        var (_, codeChallenge) = GeneratePkce();
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read",
            ["code_challenge"] = codeChallenge,
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };
        var authResp = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        var authCode = System.Web.HttpUtility.ParseQueryString(new Uri(authResp.Headers.Location!.ToString()).Query)["code"]!;

        // Attempt exchange with WRONG verifier
        var exchangeForm = new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = "wrong-verifier-123456789012345678901234567890"
        };

        var response = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(exchangeForm));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("invalid_grant", doc.RootElement.GetProperty("error").GetString());
    }

    [Fact]
    public async Task Authorization_code_cannot_be_reused()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        const string redirectUri = "http://localhost:5000/callback";
        var reg = await client.PostAsJsonAsync("/oauth/register", new { client_name = "Replay Test", redirect_uris = new[] { redirectUri } });
        var clientId = JsonDocument.Parse(await reg.Content.ReadAsStringAsync()).RootElement.GetProperty("client_id").GetString()!;

        var (verifier, challenge) = GeneratePkce();
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read",
            ["code_challenge"] = challenge,
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };
        var authResp = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        var authCode = System.Web.HttpUtility.ParseQueryString(new Uri(authResp.Headers.Location!.ToString()).Query)["code"]!;

        var exchangeForm = new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = verifier
        };

        // First exchange succeeds
        var first = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(exchangeForm));
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);

        // Second exchange with same code must fail
        var second = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(exchangeForm));
        Assert.Equal(HttpStatusCode.BadRequest, second.StatusCode);

        using var doc = JsonDocument.Parse(await second.Content.ReadAsStringAsync());
        Assert.Equal("invalid_grant", doc.RootElement.GetProperty("error").GetString());
    }

    // ── 4. Token Refresh & Revocation ────────────────────────────────────────

    [Fact]
    public async Task Refresh_token_flow_issues_new_access_token()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        const string redirectUri = "http://localhost:5000/callback";
        var reg = await client.PostAsJsonAsync("/oauth/register", new { client_name = "Refresh Test", redirect_uris = new[] { redirectUri } });
        var clientId = JsonDocument.Parse(await reg.Content.ReadAsStringAsync()).RootElement.GetProperty("client_id").GetString()!;

        var (verifier, challenge) = GeneratePkce();
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read+write",
            ["code_challenge"] = challenge,
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };
        var authResp = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        var authCode = System.Web.HttpUtility.ParseQueryString(new Uri(authResp.Headers.Location!.ToString()).Query)["code"]!;

        var exchangeResp = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = verifier
        }));

        var initialTokens = JsonDocument.Parse(await exchangeResp.Content.ReadAsStringAsync()).RootElement;
        var refreshToken = initialTokens.GetProperty("refresh_token").GetString()!;

        // Refresh token call
        var refreshResp = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "refresh_token",
            ["client_id"] = clientId,
            ["refresh_token"] = refreshToken
        }));

        Assert.Equal(HttpStatusCode.OK, refreshResp.StatusCode);
        var refreshedTokens = JsonDocument.Parse(await refreshResp.Content.ReadAsStringAsync()).RootElement;
        var newAccessToken = refreshedTokens.GetProperty("access_token").GetString()!;

        Assert.NotNull(newAccessToken);
        Assert.StartsWith(McpOAuthSecurity.AccessTokenPrefix, newAccessToken);

        // Verify the refreshed access token works on /mcp
        using var mcpClient = CreateClient(factory);
        mcpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", newAccessToken);
        using var init = await PostRpcAsync(mcpClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, init.StatusCode);
    }

    [Fact]
    public async Task Revoked_token_is_immediately_refused_on_mcp()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        const string redirectUri = "http://localhost:5000/callback";
        var reg = await client.PostAsJsonAsync("/oauth/register", new { client_name = "Revoke Test", redirect_uris = new[] { redirectUri } });
        var clientId = JsonDocument.Parse(await reg.Content.ReadAsStringAsync()).RootElement.GetProperty("client_id").GetString()!;

        var (verifier, challenge) = GeneratePkce();
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read",
            ["code_challenge"] = challenge,
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };
        var authResp = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        var authCode = System.Web.HttpUtility.ParseQueryString(new Uri(authResp.Headers.Location!.ToString()).Query)["code"]!;

        var exchangeResp = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = verifier
        }));

        var accessToken = JsonDocument.Parse(await exchangeResp.Content.ReadAsStringAsync()).RootElement
            .GetProperty("access_token").GetString()!;

        // Token works initially
        using var mcpClient = CreateClient(factory);
        mcpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        using var initBefore = await PostRpcAsync(mcpClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, initBefore.StatusCode);

        // Revoke token (RFC 7009)
        var revokeResp = await client.PostAsync("/oauth/revoke", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["token"] = accessToken,
            ["token_type_hint"] = "access_token",
            ["client_id"] = clientId
        }));
        Assert.Equal(HttpStatusCode.OK, revokeResp.StatusCode);

        // Token is now refused on /mcp with 401
        using var initAfter = await PostRpcAsync(mcpClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, initAfter.StatusCode);
    }

    // ── 5. User Authorizations REST API ──────────────────────────────────────

    [Fact]
    public async Task User_authorizations_api_allows_listing_and_revoking()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = CreateClient(factory);

        const string redirectUri = "http://localhost:5000/callback";
        var reg = await client.PostAsJsonAsync("/oauth/register", new { client_name = "My Assistant", redirect_uris = new[] { redirectUri } });
        var clientId = JsonDocument.Parse(await reg.Content.ReadAsStringAsync()).RootElement.GetProperty("client_id").GetString()!;

        var (verifier, challenge) = GeneratePkce();
        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["redirect_uri"] = redirectUri,
            ["scope"] = "read",
            ["code_challenge"] = challenge,
            ["action"] = "approve",
            ["email"] = "member@example.invalid",
            ["password"] = "Password123!"
        };
        var authResp = await client.PostAsync("/oauth/authorize", new FormUrlEncodedContent(form));
        var authCode = System.Web.HttpUtility.ParseQueryString(new Uri(authResp.Headers.Location!.ToString()).Query)["code"]!;

        var tokenResp = await client.PostAsync("/oauth/token", new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["client_id"] = clientId,
            ["code"] = authCode,
            ["redirect_uri"] = redirectUri,
            ["code_verifier"] = verifier
        }));
        var accessToken = JsonDocument.Parse(await tokenResp.Content.ReadAsStringAsync()).RootElement
            .GetProperty("access_token").GetString()!;

        // Access via authenticated user API
        using var userClient = factory.ClientFor("member");
        using var listResp = await userClient.GetAsync("/api/me/oauth-authorizations");
        Assert.Equal(HttpStatusCode.OK, listResp.StatusCode);

        using var doc = JsonDocument.Parse(await listResp.Content.ReadAsStringAsync());
        var list = doc.RootElement.EnumerateArray().ToList();
        var item = Assert.Single(list);
        Assert.Equal("My Assistant", item.GetProperty("clientName").GetString());
        Assert.Equal("read", item.GetProperty("scope").GetString());
        var tokenId = item.GetProperty("id").GetGuid();

        // Revoke via user API
        using var delResp = await userClient.DeleteAsync($"/api/me/oauth-authorizations/{tokenId}");
        Assert.Equal(HttpStatusCode.NoContent, delResp.StatusCode);

        // Verify MCP request is now rejected
        using var mcpClient = CreateClient(factory);
        mcpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        using var init = await PostRpcAsync(mcpClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, init.StatusCode);
    }
}
