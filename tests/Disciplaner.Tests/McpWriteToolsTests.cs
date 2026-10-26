using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Lot 03 — ticket and comment write tools. Synthetic fixtures only (D08).
/// </summary>
public class McpWriteToolsTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";

    private static async Task<HttpClient> McpClientAsync(ApiFactory factory, string user, string scopes = "read+write")
    {
        using var api = factory.ClientFor(user);
        using var created = await api.PostAsync("/api/me/mcp-tokens",
            new StringContent($$"""{"name":"lot03","scopes":"{{scopes}}"}""", Encoding.UTF8, "application/json"));
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

    internal static string? GetStringOrNull(JsonElement element, string name)
        => element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString() : null;

    // ── Happy paths ──────────────────────────────────────────────────────────

    [Fact]
    public async Task Member_creates_updates_assigns_moves_and_comments_a_ticket()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        // Create (FIXA already holds tickets 1 and 2)
        var (ok, msg, created) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Write the login page","type":"Bug","priority":"High","story_points":5,"description":"It 500s on submit"}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("FIXA-3", created.GetProperty("ticketRef").GetString());
        Assert.Equal("FIXA-3", created.GetProperty("ticket").GetProperty("ticketRef").GetString());
        Assert.Contains("/tickets/FIXA-3", created.GetProperty("url").GetString());
        Assert.Equal("Bug", created.GetProperty("ticket").GetProperty("type").GetString());
        Assert.Equal("High", created.GetProperty("ticket").GetProperty("priority").GetString());
        Assert.Equal("To Do", created.GetProperty("ticket").GetProperty("status").GetString());

        // Update: only the changed fields move
        var (ok2, msg2, updated) = await CallToolAsync(client, "update_ticket",
            """{"ticket_ref":"FIXA-3","title":"Fix the login page","priority":"Critical"}""", 3);
        Assert.False(ok2, msg2);
        Assert.Equal("Fix the login page", updated.GetProperty("ticket").GetProperty("title").GetString());
        Assert.Equal("Critical", updated.GetProperty("ticket").GetProperty("priority").GetString());
        Assert.Equal("It 500s on submit", updated.GetProperty("ticket").GetProperty("description").GetString());

        // Assign, then unassign
        var (ok3, msg3, assigned) = await CallToolAsync(client, "assign_ticket",
            """{"ticket_ref":"FIXA-3","assignee_display_name":"supervisor"}""", 4);
        Assert.False(ok3, msg3);
        Assert.Equal("supervisor", assigned.GetProperty("ticket").GetProperty("assignee").GetString());
        var (ok4, msg4, unassigned) = await CallToolAsync(client, "assign_ticket",
            """{"ticket_ref":"FIXA-3"}""", 5);
        Assert.False(ok4, msg4);
        Assert.Null(GetStringOrNull(unassigned.GetProperty("ticket"), "assignee"));

        // Move into the sprint, then back to the backlog
        var (ok5, msg5, moved) = await CallToolAsync(client, "move_ticket_to_sprint",
            """{"ticket_ref":"FIXA-3","sprint_name":"baseline sprint"}""", 6);
        Assert.False(ok5, msg5);
        Assert.Equal("Baseline sprint", moved.GetProperty("ticket").GetProperty("sprintName").GetString());
        var (ok6, msg6, backlog) = await CallToolAsync(client, "move_ticket_to_sprint",
            """{"ticket_ref":"FIXA-3"}""", 7);
        Assert.False(ok6, msg6);
        Assert.Null(GetStringOrNull(backlog.GetProperty("ticket"), "sprintName"));

        // Comment and read back
        var (ok7, msg7, comment) = await CallToolAsync(client, "add_comment",
            """{"ticket_ref":"FIXA-3","body":"Reproduced on staging."}""", 8);
        Assert.False(ok7, msg7);
        Assert.Equal("member", comment.GetProperty("author").GetString());
        var (ok8, msg8, comments) = await CallToolAsync(client, "list_comments",
            """{"ticket_ref":"FIXA-3"}""", 9);
        Assert.False(ok8, msg8);
        Assert.Equal(1, comments.GetProperty("items").GetArrayLength());
        Assert.Equal("Reproduced on staging.", comments.GetProperty("items")[0].GetProperty("content").GetString());

        // The ticket history (REST) records the created event — readable by the project owner.
        using var api = factory.ClientFor("owner");
        using var byRef = await api.GetAsync("/api/tickets/by-ref/FIXA/3");
        Assert.Equal(HttpStatusCode.OK, byRef.StatusCode);
        using var byRefPayload = JsonDocument.Parse(await byRef.Content.ReadAsStringAsync());
        var createdTicketId = byRefPayload.RootElement.GetProperty("id").GetGuid();

        using var history = await api.GetAsync($"/api/tickets/{createdTicketId}/history");
        Assert.Equal(HttpStatusCode.OK, history.StatusCode);
        using var historyPayload = JsonDocument.Parse(await history.Content.ReadAsStringAsync());
        Assert.Contains(historyPayload.RootElement.EnumerateArray(),
            e => e.GetProperty("kind").GetString() == "created");
    }

    [Fact]
    public async Task Create_ticket_supports_sprint_parent_and_default_type()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok, msg, created) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Investigate flaky test","sprint_name":"Baseline sprint"}""", 2);
        Assert.False(ok, msg);
        // Defaults: type Task, priority Medium, no description
        Assert.Equal("Task", created.GetProperty("ticket").GetProperty("type").GetString());
        Assert.Equal("Medium", created.GetProperty("ticket").GetProperty("priority").GetString());
        Assert.Equal("Baseline sprint", created.GetProperty("ticket").GetProperty("sprintName").GetString());

        var (ok2, msg2, subtask) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Fix the auth flake","type":"Subtask","parent_ticket_ref":"FIXA-1"}""", 3);
        Assert.False(ok2, msg2);
        Assert.Equal("FIXA-1", subtask.GetProperty("ticket").GetProperty("parentTicketRef").GetString());
    }

    // ── Scope and permission ────────────────────────────────────────────────

    [Fact]
    public async Task Read_scope_tokens_are_refused_on_every_write_tool()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member", scopes: "read");

        var calls = new (string Tool, string Args)[]
        {
            ("create_ticket", """{"project_key":"FIXA","title":"nope"}"""),
            ("update_ticket", """{"ticket_ref":"FIXA-1","title":"nope"}"""),
            ("assign_ticket", """{"ticket_ref":"FIXA-1","assignee_display_name":"member"}"""),
            ("move_ticket_to_sprint", """{"ticket_ref":"FIXA-1"}"""),
            ("add_comment", """{"ticket_ref":"FIXA-1","body":"nope"}"""),
        };
        var id = 2;
        foreach (var (tool, args) in calls)
        {
            var (isError, message, _) = await CallToolAsync(client, tool, args, id++);
            Assert.True(isError, $"tool {tool} must refuse a read-only token");
            Assert.Contains("read-only", message);
        }
    }

    [Fact]
    public async Task Guests_are_refused_by_the_role_matrix()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "guest");

        var (isError, message, _) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Should not work"}""", 2);
        Assert.True(isError);
        Assert.Contains("permission", message);
    }

    // ── Actionable errors ──────────────────────────────────────────────────

    [Fact]
    public async Task Invalid_enums_members_and_cross_project_relations_give_actionable_errors()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (isError, message, _) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Bad type","type":"Feature"}""", 2);
        Assert.True(isError);
        Assert.Contains("not a valid ticket type", message);
        Assert.Contains("Story, Bug, Task, Epic, Subtask", message);

        var (err2, message2, _) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Bad assignee","assignee_display_name":"nobody"}""", 3);
        Assert.True(err2);
        Assert.Contains("Member 'nobody' was not found in project FIXA", message2);
        Assert.Contains("owner", message2); // known members are listed

        // Parent ticket from an inaccessible project resolves to an explicit message.
        var (err3, message3, _) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Bad parent","parent_ticket_ref":"FIXB-1"}""", 4);
        Assert.True(err3);
        Assert.Contains("FIXB-1", message3);

        // An unknown sprint name lists the known sprints.
        var (err4, message4, _) = await CallToolAsync(client, "create_ticket",
            """{"project_key":"FIXA","title":"Bad sprint","sprint_name":"Nope"}""", 5);
        Assert.True(err4);
        Assert.Contains("Baseline sprint", message4);
    }
}

