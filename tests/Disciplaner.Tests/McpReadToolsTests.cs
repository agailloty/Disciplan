using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Disciplaner.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Lot 02 — MCP read tools and reference resolution. Synthetic fixtures only (D08).
/// </summary>
public class McpReadToolsTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";

    private static async Task<HttpClient> McpClientAsync(ApiFactory factory, string user, string scopes = "read")
    {
        using var api = factory.ClientFor(user);
        using var created = await api.PostAsync("/api/me/mcp-tokens",
            new StringContent($$"""{"name":"lot02","scopes":"{{scopes}}"}""", Encoding.UTF8, "application/json"));
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

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        var body = await response.Content.ReadAsStringAsync();
        if ((response.Content.Headers.ContentType?.MediaType ?? "").Contains("text/event-stream"))
        {
            body = body.Split('\n')
                .FirstOrDefault(line => line.StartsWith("data:", StringComparison.Ordinal))?["data:".Length..].Trim()
                ?? body;
        }
        using var document = JsonDocument.Parse(body);
        return document.RootElement.Clone();
    }

    /// <summary>Calls a tool and returns (isError, message, structuredResult).</summary>
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
        var root = await BodyAsync(response);

        // JSON-RPC protocol-level error (tool threw)
        if (root.TryGetProperty("error", out var protocolError) && protocolError.ValueKind != JsonValueKind.Null)
            return (true, protocolError.GetProperty("message").GetString() ?? "", default);

        var result = root.GetProperty("result");
        if (result.TryGetProperty("isError", out var isError) && isError.GetBoolean())
        {
            var message = result.TryGetProperty("content", out var content) && content.GetArrayLength() > 0
                ? content[0].GetProperty("text").GetString() ?? ""
                : "";
            return (true, message, default);
        }

        if (result.TryGetProperty("structuredContent", out var structured)
            && structured.ValueKind == JsonValueKind.Object)
            return (false, "", structured);

        var text = result.GetProperty("content")[0].GetProperty("text").GetString() ?? "";
        return (false, "", JsonDocument.Parse(text).RootElement.Clone());
    }

    private static async Task<JsonElement> ListToolsAsync(HttpClient client)
    {
        using var response = await RpcAsync(client, """{"jsonrpc":"2.0","id":99,"method":"tools/list"}""");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var root = await BodyAsync(response);
        return root.GetProperty("result").GetProperty("tools");
    }

    // ── Tool catalog ────────────────────────────────────────────────────────

    [Fact]
    public async Task Tools_list_exposes_the_nine_read_tools_with_readOnly_hint()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var tools = await ListToolsAsync(client);
        var byName = tools.EnumerateArray()
            .Where(t => t.GetProperty("name").GetString() is not null)
            .ToDictionary(t => t.GetProperty("name").GetString()!);

        string[] expected =
        [
            "list_projects", "get_project", "list_members", "list_ticket_statuses", "list_labels",
            "list_sprints", "get_sprint", "get_ticket", "list_comments"
        ];
        foreach (var name in expected)
        {
            Assert.Contains(name, byName.Keys);
            Assert.True(byName[name].GetProperty("annotations").GetProperty("readOnlyHint").GetBoolean(),
                $"tool {name} must declare readOnlyHint");
        }
        Assert.Contains("ping", byName.Keys);
    }

    [Fact]
    public async Task Tool_descriptions_are_in_english_and_document_the_ticket_reference_format()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var tools = await ListToolsAsync(client);
        var getTicket = tools.EnumerateArray().Single(t => t.GetProperty("name").GetString() == "get_ticket");
        var description = getTicket.GetProperty("description").GetString() ?? "";
        Assert.Contains("DISC-42", description);
        Assert.DoesNotContain("é", description); // English descriptions only
    }

    // ── Guests and role checks ───────────────────────────────────────────────

    [Fact]
    public async Task Guest_reads_project_tickets_and_comments()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "guest");

        var (isError, message, projects) = await CallToolAsync(client, "list_projects", "{}", 2);
        Assert.False(isError, message);
        var project = Assert.Single(projects.GetProperty("items").EnumerateArray());
        Assert.Equal("FIXA", project.GetProperty("projectKey").GetString());
        Assert.Equal("Guest", project.GetProperty("yourRole").GetString());

        var (err2, msg2, ticket) = await CallToolAsync(client, "get_ticket", """{"ticket_ref":"FIXA-1"}""", 3);
        Assert.False(err2, msg2);
        Assert.Equal("FIXA-1", ticket.GetProperty("ticketRef").GetString());
        Assert.Equal("FIXA", ticket.GetProperty("projectKey").GetString());
        Assert.Equal("Fixture ticket 00000", ticket.GetProperty("title").GetString());
        Assert.Equal("Task", ticket.GetProperty("type").GetString());

        var (err3, msg3, comments) = await CallToolAsync(client, "list_comments", """{"ticket_ref":"FIXA-1"}""", 4);
        Assert.False(err3, msg3);
        var comment = Assert.Single(comments.GetProperty("items").EnumerateArray());
        Assert.Equal("Synthetic ticket comment", comment.GetProperty("content").GetString());
        Assert.Equal("member", comment.GetProperty("author").GetString());
    }

    [Fact]
    public async Task Non_member_gets_actionable_errors()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member"); // member of FIXA only, not FIXB

        // Ticket exists but its project is not accessible → permission error, actionable.
        var (isError, message, _) = await CallToolAsync(client, "get_ticket", """{"ticket_ref":"FIXB-1"}""", 2);
        Assert.True(isError);
        Assert.Contains("permission", message);

        // Project key outside the accessible projects → listed alternatives.
        var (err2, message2, _) = await CallToolAsync(client, "get_project", """{"project_key":"FIXB"}""", 3);
        Assert.True(err2);
        Assert.Contains("FIXB", message2);
        Assert.Contains("FIXA", message2); // available keys are listed
    }

    // ── Reference resolution ─────────────────────────────────────────────────

    [Fact]
    public async Task Ticket_references_resolve_case_insensitively_and_unknown_refs_are_actionable()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok1, msg1, lower) = await CallToolAsync(client, "get_ticket", """{"ticket_ref":"fixa-1"}""", 2);
        Assert.False(ok1, msg1);
        Assert.Equal("FIXA-1", lower.GetProperty("ticketRef").GetString());

        var (isError, message, _) = await CallToolAsync(client, "get_ticket", """{"ticket_ref":"FIXA-99"}""", 3);
        Assert.True(isError);
        Assert.Contains("FIXA-99", message);
        Assert.Contains("list_tickets", message);

        var (err3, message3, _) = await CallToolAsync(client, "get_ticket", """{"ticket_ref":"garbage"}""", 4);
        Assert.True(err3);
        Assert.Contains("not a valid ticket reference", message3);

        // Resolving by GUID id also works.
        var (err4, msg4, byId) = await CallToolAsync(client, "get_ticket",
            $$"""{"ticket_id":"{{BaselineFixture.Id("ticket-0")}}"}""", 5);
        Assert.False(err4, msg4);
        Assert.Equal("FIXA-1", byId.GetProperty("ticketRef").GetString());
    }

    [Fact]
    public async Task Ambiguous_sprint_name_lists_candidates()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // Seed a second sprint with the same name in the shared project.
        // Inserted via raw SQL: the Sprint constructor is internal to the Domain and
        // Project.AddSprint would conflict with the fixture's frozen project row
        // (optimistic concurrency on NextTicketNumber).
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var projectId = await db.Projects.Where(p => p.Key == "FIXA").Select(p => p.Id).SingleAsync();
            await db.Database.ExecuteSqlRawAsync(
                "INSERT INTO Sprints (Id, Name, Goal, Status, CreatedAt, ProjectId) " +
                "VALUES ({0}, 'Baseline sprint', 'Duplicate name on purpose', 0, {1}, {2})",
                Guid.NewGuid(), DateTime.UtcNow, projectId);
        }

        using var client = await McpClientAsync(factory, "member");
        var (isError, message, _) = await CallToolAsync(client, "get_sprint",
            """{"sprint_name":"Baseline sprint","project_key":"FIXA"}""", 2);
        Assert.True(isError);
        Assert.Contains("Multiple sprints named 'Baseline sprint'", message);
        Assert.Contains("sprint_id", message); // disambiguation path is explained
    }

    // ── Sprints and project details ─────────────────────────────────────────

    [Fact]
    public async Task Get_sprint_returns_its_tickets_and_list_sprints_scopes_to_accessible_projects()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok, msg, sprint) = await CallToolAsync(client, "get_sprint",
            """{"sprint_name":"Baseline sprint","project_key":"FIXA"}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("Planned", sprint.GetProperty("status").GetString());
        Assert.Equal(2, sprint.GetProperty("tickets").GetArrayLength());
        Assert.Contains("FIXA-1", sprint.GetProperty("tickets").EnumerateArray()
            .Select(t => t.GetProperty("ticketRef").GetString()));

        // Without project_key: only sprints of accessible projects (FIXA, not FIXB).
        var (ok2, msg2, sprints) = await CallToolAsync(client, "list_sprints", "{}", 3);
        Assert.False(ok2, msg2);
        var sprintItem = Assert.Single(sprints.GetProperty("items").EnumerateArray());
        Assert.Equal("FIXA", sprintItem.GetProperty("projectKey").GetString());
        Assert.NotNull(sprintItem.GetProperty("sprintId").GetString()); // id needed by sprint tools
    }

    [Fact]
    public async Task Get_project_returns_statuses_members_and_defaults()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok, msg, project) = await CallToolAsync(client, "get_project", """{"project_key":"fixa"}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("FIXA", project.GetProperty("projectKey").GetString());
        Assert.True(project.GetProperty("statuses").GetArrayLength() > 0);
        Assert.True(project.GetProperty("members").GetArrayLength() >= 4);
        Assert.Equal("Member", project.GetProperty("yourRole").GetString());
        Assert.Contains("Guest", project.GetProperty("members").EnumerateArray()
            .Select(m => m.GetProperty("role").GetString()));
    }

    [Fact]
    public async Task List_ticket_statuses_returns_categories()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok, msg, statuses) = await CallToolAsync(client, "list_ticket_statuses", """{"project_key":"FIXA"}""", 2);
        Assert.False(ok, msg);
        Assert.True(statuses.GetProperty("items").GetArrayLength() > 0);
        foreach (var status in statuses.GetProperty("items").EnumerateArray())
        {
            var category = status.GetProperty("category").GetString();
            Assert.Contains(category, new[] { "Backlog", "InProgress", "Done" });
        }
    }

    // ── Pagination ────────────────────────────────────────────────────────────

    [Fact]
    public async Task Pagination_refuses_limits_above_100_and_pages_members()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (isError, message, _) = await CallToolAsync(client, "list_projects", """{"limit":200}""", 2);
        Assert.True(isError);
        Assert.Contains("at most 100", message);

        // Members of FIXA: owner, guest, member, supervisor → 4 total.
        var (ok1, msg1, page1) = await CallToolAsync(client, "list_members",
            """{"project_key":"FIXA","limit":2,"offset":0}""", 3);
        Assert.False(ok1, msg1);
        Assert.Equal(2, page1.GetProperty("items").GetArrayLength());
        Assert.Equal(4, page1.GetProperty("totalCount").GetInt32());

        var (ok2, msg2, page2) = await CallToolAsync(client, "list_members",
            """{"project_key":"FIXA","limit":2,"offset":2}""", 4);
        Assert.False(ok2, msg2);
        Assert.Equal(2, page2.GetProperty("items").GetArrayLength());

        var (err3, msg3, page3) = await CallToolAsync(client, "list_members",
            """{"project_key":"FIXA","offset":4}""", 5);
        Assert.False(err3, msg3);
        Assert.Equal(0, page3.GetProperty("items").GetArrayLength());
    }

    [Fact]
    public async Task List_labels_returns_the_global_catalog()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var (ok, msg, labels) = await CallToolAsync(client, "list_labels", "{}", 2);
        Assert.False(ok, msg);
        Assert.Equal(0, labels.GetProperty("totalCount").GetInt32()); // no label in the fixture
    }
}
