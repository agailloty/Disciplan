using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Lot 04 — sprint lifecycle tools. Synthetic fixtures only (D08).
/// Sprint creation, start and close require the Supervisor project role (application rule).
/// </summary>
public class McpSprintToolsTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";

    private static async Task<HttpClient> McpClientAsync(ApiFactory factory, string user, string scopes = "read+write")
    {
        using var api = factory.ClientFor(user);
        using var created = await api.PostAsync("/api/me/mcp-tokens",
            new StringContent($$"""{"name":"lot04","scopes":"{{scopes}}"}""", Encoding.UTF8, "application/json"));
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);
        using var payload = JsonDocument.Parse(await created.Content.ReadAsStringAsync());
        var raw = payload.RootElement.GetProperty("token").GetString();
        Assert.StartsWith(McpTokenSecurity.RawPrefix, raw);

        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
            { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", raw);
        using var init = await RpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, init.StatusCode);
        return client;
    }

    private static async Task<HttpResponseMessage> RpcAsync(HttpClient client, string json)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/mcp")
        {
            Content = new StringContent(json, Encoding.UTF8, "application/json")
        };
        request.Headers.Accept.ParseAdd("application/json");
        request.Headers.Accept.ParseAdd("text/event-stream");
        return await client.SendAsync(request);
    }

    private static async Task<(bool IsError, string Message, JsonElement Result)> CallToolAsync(
        HttpClient client, string tool, string argumentsJson, int id)
    {
        var request = new System.Text.Json.Nodes.JsonObject
        {
            ["jsonrpc"] = "2.0",
            ["id"] = id,
            ["method"] = "tools/call",
            ["params"] = new System.Text.Json.Nodes.JsonObject
            {
                ["name"] = tool,
                ["arguments"] = System.Text.Json.Nodes.JsonNode.Parse(argumentsJson)
                    ?? new System.Text.Json.Nodes.JsonObject()
            }
        };
        using var response = await RpcAsync(client, request.ToJsonString());
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        if ((response.Content.Headers.ContentType?.MediaType ?? "").Contains("text/event-stream"))
            body = body.Split('\n').FirstOrDefault(l => l.StartsWith("data:", StringComparison.Ordinal))?["data:".Length..].Trim() ?? body;
        using var document = JsonDocument.Parse(body);
        var root = document.RootElement.Clone();

        if (root.TryGetProperty("error", out var protocolError) && protocolError.ValueKind != JsonValueKind.Null)
            return (true, protocolError.GetProperty("message").GetString() ?? "", default);

        var result = root.GetProperty("result");
        if (result.TryGetProperty("isError", out var isError) && isError.GetBoolean())
        {
            var message = result.TryGetProperty("content", out var content) && content.GetArrayLength() > 0
                ? content[0].GetProperty("text").GetString() ?? "" : "";
            return (true, message, default);
        }
        if (result.TryGetProperty("structuredContent", out var structured) && structured.ValueKind == JsonValueKind.Object)
            return (false, "", structured);
        return (false, "", JsonDocument.Parse(result.GetProperty("content")[0].GetProperty("text").GetString() ?? "{}").RootElement.Clone());
    }

    private static string? GetStringOrNull(JsonElement element, string name)
        => element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString() : null;

    [Fact]
    public async Task Sprint_lifecycle_runs_entirely_through_tools()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "supervisor");

        // Create
        var (ok, msg, created) = await CallToolAsync(client, "create_sprint",
            """{"project_key":"FIXA","name":"Sprint 42","goal":"Ship the connector"}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("Sprint 42", created.GetProperty("name").GetString());
        Assert.Equal("Planned", created.GetProperty("status").GetString());
        Assert.Equal("FIXA", created.GetProperty("projectKey").GetString());
        var sprintId = created.GetProperty("sprintId").GetString();
        Assert.NotNull(sprintId);

        // Plan a ticket into it
        var (okMove, msgMove, _) = await CallToolAsync(client, "move_ticket_to_sprint",
            $$"""{"ticket_ref":"FIXA-1","sprint_id":"{{sprintId}}"}""", 3);
        Assert.False(okMove, msgMove);

        // Ambiguity: a second sprint with the same name makes name-based calls list candidates
        var (okDup, msgDup, _) = await CallToolAsync(client, "create_sprint",
            """{"project_key":"FIXA","name":"Sprint 42"}""", 4);
        Assert.False(okDup, msgDup);
        var (isAmbiguous, ambiguousMessage, _) = await CallToolAsync(client, "start_sprint",
            """{"sprint_name":"Sprint 42","project_key":"FIXA","start_date":"2026-10-27","end_date":"2026-11-09"}""", 5);
        Assert.True(isAmbiguous);
        Assert.Contains("Multiple sprints named 'Sprint 42'", ambiguousMessage);
        Assert.Contains("sprint_id", ambiguousMessage);

        // Start by id
        var (okStart, msgStart, started) = await CallToolAsync(client, "start_sprint",
            $$"""{"sprint_id":"{{sprintId}}","start_date":"2026-10-27","end_date":"2026-11-09"}""", 6);
        Assert.False(okStart, msgStart);
        Assert.Equal("Active", started.GetProperty("status").GetString());
        Assert.Equal("2026-10-27", GetStringOrNull(started, "startDate"));

        // A second concurrent start is refused with the domain message
        var (okB, msgB, sprintB) = await CallToolAsync(client, "create_sprint",
            """{"project_key":"FIXA","name":"Sprint 43"}""", 7);
        Assert.False(okB, msgB);
        var (isError, message, _) = await CallToolAsync(client, "start_sprint",
            $$"""{"sprint_id":"{{sprintB.GetProperty("sprintId").GetString()}}","start_date":"2026-10-28","end_date":"2026-11-10"}""", 8);
        Assert.True(isError);
        Assert.Contains("ctive", message); // "An active sprint already exists" (domain wording)

        // Update dates, then close
        var (okUpdate, msgUpdate, updated) = await CallToolAsync(client, "update_sprint",
            $$"""{"sprint_id":"{{sprintId}}","goal":"Ship the connector and its docs"}""", 9);
        Assert.False(okUpdate, msgUpdate);
        Assert.Equal("Ship the connector and its docs", GetStringOrNull(updated, "goal"));

        var (okClose, msgClose, closed) = await CallToolAsync(client, "close_sprint",
            $$"""{"sprint_id":"{{sprintId}}"}""", 10);
        Assert.False(okClose, msgClose);
        Assert.Equal("Closed", closed.GetProperty("status").GetString());

        // Editing a closed sprint is refused with the domain message
        var (errClosed, messageClosed, _) = await CallToolAsync(client, "update_sprint",
            $$"""{"sprint_id":"{{sprintId}}","name":"Nope"}""", 11);
        Assert.True(errClosed);
        Assert.Contains("closed sprint cannot be edited", messageClosed);

        // get_sprint confirms the final state
        var (okGet, msgGet, sprint) = await CallToolAsync(client, "get_sprint",
            $$"""{"sprint_id":"{{sprintId}}"}""", 12);
        Assert.False(okGet, msgGet);
        Assert.Equal("Closed", sprint.GetProperty("status").GetString());
        Assert.Contains("FIXA-1", sprint.GetProperty("tickets").EnumerateArray()
            .Select(t => t.GetProperty("ticketRef").GetString()));
    }

    [Fact]
    public async Task Members_cannot_manage_sprints_and_read_tokens_cannot_write()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // Supervisor role is required: a plain Member is refused by the role matrix.
        using var member = await McpClientAsync(factory, "member");
        var (isError, message, _) = await CallToolAsync(member, "create_sprint",
            """{"project_key":"FIXA","name":"Not allowed"}""", 2);
        Assert.True(isError);
        Assert.Contains("permission", message);

        // A read-only token is refused on all four lifecycle tools.
        using var supervisor = await McpClientAsync(factory, "supervisor", scopes: "read");
        var calls = new (string Tool, string Args)[]
        {
            ("create_sprint", """{"project_key":"FIXA","name":"Nope"}"""),
            ("start_sprint", """{"sprint_name":"Baseline sprint","project_key":"FIXA","start_date":"2026-10-27","end_date":"2026-11-09"}"""),
            ("close_sprint", """{"sprint_name":"Baseline sprint","project_key":"FIXA"}"""),
            ("update_sprint", """{"sprint_name":"Baseline sprint","project_key":"FIXA","goal":"Nope"}"""),
        };
        var id = 2;
        foreach (var (tool, args) in calls)
        {
            var (err, msg, _) = await CallToolAsync(supervisor, tool, args, id++);
            Assert.True(err, $"tool {tool} must refuse a read-only token");
            Assert.Contains("read-only", msg);
        }
    }

    [Fact]
    public async Task Invalid_dates_and_unknown_sprints_give_actionable_errors()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "supervisor");

        var (ok, msg, created) = await CallToolAsync(client, "create_sprint",
            """{"project_key":"FIXA","name":"Bad dates"}""", 2);
        Assert.False(ok, msg);
        var sprintId = created.GetProperty("sprintId").GetString();

        var (errDates, msgDates, _) = await CallToolAsync(client, "start_sprint",
            $$"""{"sprint_id":"{{sprintId}}","start_date":"eventually","end_date":"2026-11-09"}""", 3);
        Assert.True(errDates);
        Assert.Contains("ISO 8601", msgDates);

        var (errUnknown, msgUnknown, _) = await CallToolAsync(client, "start_sprint",
            """{"sprint_name":"Nope","project_key":"FIXA","start_date":"2026-10-27","end_date":"2026-11-09"}""", 4);
        Assert.True(errUnknown);
        Assert.Contains("Sprint 'Nope' was not found in project FIXA", msgUnknown);
        Assert.Contains("Baseline sprint", msgUnknown);
    }
}
