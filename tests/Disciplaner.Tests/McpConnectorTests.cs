using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Disciplaner.Infrastructure.Data;
using Disciplaner.Mcp.McpAuth;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Lot 01 — MCP connector foundation: PAT authentication on /mcp and token management REST API.
/// Synthetic fixtures only (D08): users come from BaselineFixture, no real data.
/// </summary>
public class McpConnectorTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";
    private const string ToolsListRequest =
        """{"jsonrpc":"2.0","id":2,"method":"tools/list"}""";

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

    /// <summary>Parses a JSON-RPC response body that may be plain JSON or an SSE event stream.</summary>
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

    private static async Task<(Guid Id, string RawToken)> CreateTokenViaApiAsync(ApiFactory factory, string user, string scopes = "read+write")
    {
        using var client = factory.ClientFor(user);
        using var response = await client.PostAsJsonAsync("/api/me/mcp-tokens",
            new { name = "test connector", scopes });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var root = payload.RootElement;
        Assert.Equal(scopes, root.GetProperty("scopes").GetString());
        var raw = root.GetProperty("token").GetString();
        Assert.NotNull(raw);
        Assert.StartsWith(McpTokenSecurity.RawPrefix, raw);
        return (root.GetProperty("id").GetGuid(), raw);
    }

    private static HttpClient ClientWithPat(ApiFactory factory, string rawToken)
    {
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            AllowAutoRedirect = false
        });
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", rawToken);
        return client;
    }

    // ── /mcp handshake ──────────────────────────────────────────────────────

    [Fact]
    public async Task Initialize_with_a_valid_pat_returns_server_info_and_lists_ping()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (_, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var client = ClientWithPat(factory, raw);
        using var initialize = await PostRpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, initialize.StatusCode);

        var result = await ReadRpcResultAsync(initialize);
        Assert.Equal(1, result.GetProperty("id").GetInt32());
        var payload = result.GetProperty("result");
        Assert.False(payload.TryGetProperty("error", out _));
        Assert.True(payload.TryGetProperty("serverInfo", out _));
        Assert.Contains("Disciplaner", payload.GetProperty("instructions").GetString());

        var sessionId = initialize.Headers.TryGetValues("mcp-session-id", out var values)
            ? values.FirstOrDefault() : null;
        using var tools = await PostRpcAsync(client, ToolsListRequest, sessionId);
        Assert.Equal(HttpStatusCode.OK, tools.StatusCode);
        var toolsResult = await ReadRpcResultAsync(tools);
        var names = toolsResult.GetProperty("result").GetProperty("tools").EnumerateArray()
            .Select(t => t.GetProperty("name").GetString());
        Assert.Contains("ping", names);
    }

    [Fact]
    public async Task Initialize_calls_the_ping_tool()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (_, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var client = ClientWithPat(factory, raw);
        await PostRpcAsync(client, InitializeRequest);
        using var ping = await PostRpcAsync(client,
            """{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"ping","arguments":{}}}""");
        Assert.Equal(HttpStatusCode.OK, ping.StatusCode);
        var result = await ReadRpcResultAsync(ping);
        Assert.True(result.GetProperty("result").GetProperty("content")[0]
            .GetProperty("text").GetString() == "pong");
    }

    // ── /mcp authentication ────────────────────────────────────────────────

    [Fact]
    public async Task Mcp_endpoint_rejects_anonymous_unknown_and_revoked_tokens()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // Anonymous
        using var anonymous = factory.CreateClient(new WebApplicationFactoryClientOptions
            { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        using var noAuth = await PostRpcAsync(anonymous, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, noAuth.StatusCode);

        // Unknown (well-formed but unregistered) PAT
        var (_, ghost) = McpTokenSecurity.Generate();
        using var ghostClient = ClientWithPat(factory, ghost);
        using var unknown = await PostRpcAsync(ghostClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, unknown.StatusCode);

        // Revoked PAT
        var (id, raw) = await CreateTokenViaApiAsync(factory, "member");
        using var ownerClient = factory.ClientFor("member");
        using var revoke = await ownerClient.DeleteAsync($"/api/me/mcp-tokens/{id}");
        Assert.Equal(HttpStatusCode.NoContent, revoke.StatusCode);
        using var revokedClient = ClientWithPat(factory, raw);
        using var revoked = await PostRpcAsync(revokedClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, revoked.StatusCode);
    }

    [Fact]
    public async Task Mcp_endpoint_rejects_the_application_jwt()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // A valid application JWT authenticates on the REST API...
        using var jwtClient = factory.ClientFor("member");
        using var projects = await jwtClient.GetAsync("/api/projects");
        Assert.Equal(HttpStatusCode.OK, projects.StatusCode);

        // ...but must NOT be accepted on /mcp.
        using var mcp = await PostRpcAsync(jwtClient, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, mcp.StatusCode);
    }

    [Fact]
    public async Task Mcp_endpoint_rejects_expired_tokens()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // Seed a token that expired in the past, with the hash of a freshly generated raw value.
        var (raw, hash) = McpTokenSecurity.Generate();
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            db.McpTokens.Add(new McpToken("member", "expired fixture token", McpTokenSecurity.ReadScope, hash,
                expiresAt: DateTime.UtcNow.AddHours(-1)));
            await db.SaveChangesAsync();
        }

        using var client = ClientWithPat(factory, raw);
        using var response = await PostRpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Mcp_endpoint_returns_404_when_disabled()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (_, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var disabled = factory.WithWebHostBuilder(
            builder => builder.UseSetting("Mcp:Enabled", "false"));
        using var client = disabled.CreateClient(new WebApplicationFactoryClientOptions
            { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", raw);
        using var response = await PostRpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ── LastUsedAt flush gating (review fix A) ──────────────────────────────

    private static async Task<DateTime?> ReadLastUsedAtAsync(ApiFactory factory, Guid tokenId)
    {
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var token = await db.McpTokens.FindAsync(tokenId);
        return token?.LastUsedAt;
    }

    [Fact]
    public async Task Mcp_requests_close_together_flush_last_used_at_only_once()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (id, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var client = ClientWithPat(factory, raw);
        await PostRpcAsync(client, InitializeRequest);
        var afterFirst = await ReadLastUsedAtAsync(factory, id);
        Assert.NotNull(afterFirst);

        // A second request within the 5-minute sliding window: telemetry is not re-persisted.
        await PostRpcAsync(client, InitializeRequest);
        var afterSecond = await ReadLastUsedAtAsync(factory, id);
        Assert.Equal(afterFirst, afterSecond);
    }

    [Fact]
    public async Task Mcp_requests_flush_last_used_at_again_after_the_five_minute_window()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (id, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var client = ClientWithPat(factory, raw);
        await PostRpcAsync(client, InitializeRequest);
        var afterFirst = await ReadLastUsedAtAsync(factory, id);
        Assert.NotNull(afterFirst);

        // Simulate more than 5 minutes without use: the sliding cache entry has expired.
        factory.Services.GetRequiredService<IMemoryCache>()
            .Remove(McpTokenAuthenticationHandler.LastUsedCacheKeyPrefix + id);

        await PostRpcAsync(client, InitializeRequest);
        var afterSecond = await ReadLastUsedAtAsync(factory, id);
        Assert.NotNull(afterSecond);
        Assert.True(afterSecond > afterFirst,
            $"expected LastUsedAt {afterSecond:O} to be later than {afterFirst:O}");
    }

    private static async Task<List<string>> ToolsListNamesAsync(HttpClient client)
    {
        using var initialize = await PostRpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, initialize.StatusCode);
        using var list = await PostRpcAsync(client, ToolsListRequest);
        Assert.Equal(HttpStatusCode.OK, list.StatusCode);
        var result = await ReadRpcResultAsync(list);
        return result.GetProperty("result").GetProperty("tools").EnumerateArray()
            .Select(t => t.GetProperty("name").GetString() ?? string.Empty)
            .ToList();
    }

    [Fact]
    public async Task Tools_list_hides_write_tools_from_read_only_tokens()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (_, raw) = await CreateTokenViaApiAsync(factory, "member", scopes: McpTokenSecurity.ReadScope);

        using var client = ClientWithPat(factory, raw);
        var names = await ToolsListNamesAsync(client);

        // Write tools are hidden...
        Assert.DoesNotContain("create_sprint", names);
        Assert.DoesNotContain("create_ticket", names);
        Assert.DoesNotContain("add_comment", names);
        // ...read tools and the side-effect-free ping stay visible: 10 ReadOnly tools + ping.
        Assert.Contains("list_sprints", names);
        Assert.Contains("get_ticket", names);
        Assert.Contains("ping", names);
        Assert.Equal(11, names.Count);
    }

    [Fact]
    public async Task Tools_list_shows_all_tools_to_read_write_tokens()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (_, raw) = await CreateTokenViaApiAsync(factory, "member");

        using var client = ClientWithPat(factory, raw);
        var names = await ToolsListNamesAsync(client);

        Assert.Contains("create_sprint", names);
        Assert.Contains("add_comment", names);
        Assert.Equal(22, names.Count);
    }

    // ── Token management REST API ───────────────────────────────────────────

    [Fact]
    public async Task Token_management_roundtrips_without_exposing_raw_values()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        using var client = factory.ClientFor("member");

        using var empty = await client.GetAsync("/api/me/mcp-tokens");
        Assert.Equal(HttpStatusCode.OK, empty.StatusCode);
        using var emptyPayload = JsonDocument.Parse(await empty.Content.ReadAsStringAsync());
        Assert.Equal(0, emptyPayload.RootElement.GetArrayLength());

        var (id, raw) = await CreateTokenViaApiAsync(factory, "member");
        Assert.StartsWith(McpTokenSecurity.RawPrefix, raw);

        using var list = await client.GetAsync("/api/me/mcp-tokens");
        using var payload = JsonDocument.Parse(await list.Content.ReadAsStringAsync());
        var tokens = payload.RootElement.EnumerateArray().ToList();
        var token = Assert.Single(tokens);
        Assert.Equal(id, token.GetProperty("id").GetGuid());
        Assert.Equal("test connector", token.GetProperty("name").GetString());
        Assert.Equal("read+write", token.GetProperty("scopes").GetString());
        Assert.Null(token.GetProperty("revokedAt").GetString());
        // The raw token must never be listed after creation.
        Assert.False(token.TryGetProperty("token", out _));

        using var revoke = await client.DeleteAsync($"/api/me/mcp-tokens/{id}");
        Assert.Equal(HttpStatusCode.NoContent, revoke.StatusCode);

        using var revokedList = await client.GetAsync("/api/me/mcp-tokens");
        using var revokedPayload = JsonDocument.Parse(await revokedList.Content.ReadAsStringAsync());
        Assert.Equal(id, revokedPayload.RootElement[0].GetProperty("id").GetGuid());
        Assert.NotNull(revokedPayload.RootElement[0].GetProperty("revokedAt").GetString());
    }

    [Fact]
    public async Task Token_management_is_scoped_to_the_owning_user()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var (id, _) = await CreateTokenViaApiAsync(factory, "member");

        // Another user cannot see or revoke it.
        using var outsider = factory.ClientFor("outsider");
        using var outsiderList = await outsider.GetAsync("/api/me/mcp-tokens");
        using var outsiderPayload = JsonDocument.Parse(await outsiderList.Content.ReadAsStringAsync());
        Assert.Equal(0, outsiderPayload.RootElement.GetArrayLength());

        using var foreignRevoke = await outsider.DeleteAsync($"/api/me/mcp-tokens/{id}");
        Assert.Equal(HttpStatusCode.NotFound, foreignRevoke.StatusCode);

        // Anonymous access is refused.
        using var anonymous = factory.CreateClient(new WebApplicationFactoryClientOptions
            { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        using var anonymousList = await anonymous.GetAsync("/api/me/mcp-tokens");
        Assert.Equal(HttpStatusCode.Unauthorized, anonymousList.StatusCode);
    }

    [Fact]
    public async Task Token_creation_rejects_invalid_scopes_and_names()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");

        using var badScope = await client.PostAsJsonAsync("/api/me/mcp-tokens",
            new { name = "bad scope", scopes = "admin" });
        Assert.Equal(HttpStatusCode.BadRequest, badScope.StatusCode);

        using var emptyName = await client.PostAsJsonAsync("/api/me/mcp-tokens",
            new { name = "  ", scopes = McpTokenSecurity.ReadScope });
        Assert.Equal(HttpStatusCode.BadRequest, emptyName.StatusCode);
    }

    // ── Salted hashing (unit) ────────────────────────────────────────────────

    [Fact]
    public void Token_hashing_is_salted_stable_and_only_accepts_wellformed_values()
    {
        var (raw, hash) = McpTokenSecurity.Generate();
        Assert.Equal(hash, McpTokenSecurity.HashOf(raw));
        Assert.NotEqual(hash, McpTokenSecurity.HashOf(raw + "x"));          // tamper detection
        Assert.Null(McpTokenSecurity.HashOf("dcp_garbage"));                // missing separator
        Assert.Null(McpTokenSecurity.HashOf("garbage"));                     // wrong prefix
        Assert.Null(McpTokenSecurity.HashOf(null));
        Assert.Null(McpTokenSecurity.HashOf(McpTokenSecurity.RawPrefix));    // prefix only
        Assert.False(McpTokenSecurity.IsValidScope("write"));
        Assert.True(McpTokenSecurity.IsValidScope(McpTokenSecurity.ReadScope));
        Assert.True(McpTokenSecurity.IsValidScope(McpTokenSecurity.ReadWriteScope));

        // Two generations never collide (256-bit secret, per-token salt).
        var (raw2, hash2) = McpTokenSecurity.Generate();
        Assert.NotEqual(raw, raw2);
        Assert.NotEqual(hash, hash2);
    }
}
