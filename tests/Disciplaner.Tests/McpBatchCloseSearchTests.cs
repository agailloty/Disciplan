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
/// Lot 05 — batch creation, ticket closing and search. Synthetic fixtures only (D08).
/// </summary>
public class McpBatchCloseSearchTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";

    private static async Task<HttpClient> McpClientAsync(ApiFactory factory, string user, string scopes = "read+write")
    {
        using var api = factory.ClientFor(user);
        using var created = await api.PostAsync("/api/me/mcp-tokens",
            new StringContent($$"""{"name":"lot05","scopes":"{{scopes}}"}""", Encoding.UTF8, "application/json"));
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

    // ── Batch creation ───────────────────────────────────────────────────────

    [Fact]
    public async Task Batch_creation_reports_partial_failures_and_enforces_limits()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = await McpClientAsync(factory, "member");

        var tooLongTitle = new string('x', 300);
        var batch = """
            {"project_key":"FIXA","tickets":[
              {"title":"Add search filters","type":"Story","story_points":3},
              {"title":"{{TOO_LONG}}"},
              {"title":"Write the docs","priority":"Low"}
            ]}
            """.Replace("{{TOO_LONG}}", tooLongTitle);

        var (ok, msg, result) = await CallToolAsync(client, "create_tickets", batch, 2);
        Assert.False(ok, msg);

        var created = result.GetProperty("created");
        Assert.Equal(2, created.GetArrayLength());
        Assert.Equal("FIXA-3", created[0].GetProperty("ticketRef").GetString());
        Assert.Equal("Add search filters", created[0].GetProperty("title").GetString());
        Assert.Contains("/tickets/FIXA-3", created[0].GetProperty("url").GetString());
        Assert.Equal("FIXA-4", created[1].GetProperty("ticketRef").GetString());

        var failed = result.GetProperty("failed");
        var failure = Assert.Single(failed.EnumerateArray());
        Assert.Equal(1, failure.GetProperty("index").GetInt32());
        Assert.Equal(tooLongTitle, failure.GetProperty("title").GetString());
        Assert.Contains("title", (failure.GetProperty("error").GetString() ?? "").ToLowerInvariant());

        // Over-limit batches are refused whole, with a clear message.
        var oversized = "{\"project_key\":\"FIXA\",\"tickets\":["
            + string.Join(",", Enumerable.Range(0, 51).Select(i => $$"""{"title":"Bulk {{i}}"}"""))
            + "]}";
        var (isError, message, _) = await CallToolAsync(client, "create_tickets", oversized, 3);
        Assert.True(isError);
        Assert.Contains("exceeds the 50-ticket limit", message);
    }

    [Fact]
    public async Task Batch_refuses_guests_and_read_only_tokens_as_a_whole()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        using var guest = await McpClientAsync(factory, "guest");
        var (isError, message, _) = await CallToolAsync(guest, "create_tickets",
            """{"project_key":"FIXA","tickets":[{"title":"Nope"},{"title":"Neither"}]}""", 2);
        Assert.True(isError);
        Assert.Contains("Member is required", message);

        using var reader = await McpClientAsync(factory, "member", scopes: "read");
        var (err, msg, _) = await CallToolAsync(reader, "create_tickets",
            """{"project_key":"FIXA","tickets":[{"title":"Nope"}]}""", 3);
        Assert.True(err);
        Assert.Contains("read-only", msg);
    }

    // ── close_ticket ─────────────────────────────────────────────────────────

    [Fact]
    public async Task Close_ticket_resolves_the_terminal_status_and_adds_the_comment()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var member = await McpClientAsync(factory, "member");

        // FIXA has the canonical "Done" status (rule a).
        var (ok, msg, closed) = await CallToolAsync(member, "close_ticket",
            """{"ticket_ref":"FIXA-1","resolution_comment":"Fixed by the connector tests."}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("FIXA-1", closed.GetProperty("ticketRef").GetString());
        Assert.Equal("Done", closed.GetProperty("ticket").GetProperty("status").GetString());
        Assert.Equal("Done", closed.GetProperty("ticket").GetProperty("statusCategory").GetString());

        var (okComments, msgComments, comments) = await CallToolAsync(member, "list_comments",
            """{"ticket_ref":"FIXA-1"}""", 3);
        Assert.False(okComments, msgComments);
        // The fixture comment plus the resolution comment, oldest first.
        Assert.Equal(2, comments.GetProperty("items").GetArrayLength());
        Assert.Equal("Synthetic ticket comment", comments.GetProperty("items")[0].GetProperty("content").GetString());
        Assert.Equal("Fixed by the connector tests.", comments.GetProperty("items")[1].GetProperty("content").GetString());
    }

    [Fact]
    public async Task Close_ticket_handles_renamed_ambiguous_and_missing_done_statuses()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var outsider = await McpClientAsync(factory, "outsider"); // owns FIXB
        var fixbDoneStatusId = BaselineFixture.Id("status-1-2");

        // Rule (c): rename the unique Done status to a non-canonical name.
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await db.Database.ExecuteSqlRawAsync("UPDATE \"TicketStatuses\" SET \"Name\" = 'Validé' WHERE \"Id\" = {0}", fixbDoneStatusId);
        }
        var (ok, msg, closed) = await CallToolAsync(outsider, "close_ticket", """{"ticket_ref":"FIXB-1"}""", 2);
        Assert.False(ok, msg);
        Assert.Equal("Validé", closed.GetProperty("ticket").GetProperty("status").GetString());

        // Ambiguity: a second, non-canonical Done status → candidates listed.
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var projectId = await db.Projects.Where(p => p.Key == "FIXB").Select(p => p.Id).SingleAsync();
            await db.Database.ExecuteSqlRawAsync(
                "INSERT INTO \"TicketStatuses\" (\"Id\", \"Name\", \"Color\", \"Order\", \"Category\", \"CreatedAt\", \"ProjectId\") " +
                "VALUES ({0}, 'Annulé', '#999999', 9, 2, {1}, {2})",
                Guid.NewGuid(), DateTime.UtcNow, projectId);
        }
        var (isAmbiguous, ambiguousMessage, _) = await CallToolAsync(outsider, "close_ticket", """{"ticket_ref":"FIXB-2"}""", 3);
        Assert.True(isAmbiguous);
        Assert.Contains("several Done statuses", ambiguousMessage);
        Assert.Contains("Validé", ambiguousMessage);
        Assert.Contains("Annulé", ambiguousMessage);

        // No Done status at all → explicit guidance.
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await db.Database.ExecuteSqlRawAsync("DELETE FROM \"TicketStatuses\" WHERE \"Category\" = 2 AND \"ProjectId\" = {0}",
                await db.Projects.Where(p => p.Key == "FIXB").Select(p => p.Id).SingleAsync());
        }
        var (noDone, noDoneMessage, _) = await CallToolAsync(outsider, "close_ticket", """{"ticket_ref":"FIXB-2"}""", 4);
        Assert.True(noDone);
        Assert.Contains("no Done status", noDoneMessage);
        Assert.Contains("To Do", noDoneMessage); // available statuses are listed
    }

    // ── list_tickets / search ──────────────────────────────────────────────

    [Fact]
    public async Task List_tickets_filters_by_status_sprint_assignee_and_scope()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var member = await McpClientAsync(factory, "member", scopes: "read");

        // All accessible projects (member only sees FIXA, never FIXB).
        var (ok, msg, page) = await CallToolAsync(member, "list_tickets", "{}", 2);
        Assert.False(ok, msg);
        Assert.Equal(2, page.GetProperty("totalCount").GetInt32());
        var refs = page.GetProperty("items").EnumerateArray().Select(t => t.GetProperty("ticketRef").GetString()).ToList();
        Assert.Equal(["FIXA-1", "FIXA-2"], refs);

        // Status category filter.
        var (okCat, msgCat, done) = await CallToolAsync(member, "list_tickets",
            """{"project_key":"FIXA","status_category":"Done"}""", 3);
        Assert.False(okCat, msgCat);
        Assert.Equal(0, done.GetProperty("totalCount").GetInt32());

        // Sprint filter by name.
        var (okSprint, msgSprint, sprintTickets) = await CallToolAsync(member, "list_tickets",
            """{"project_key":"FIXA","sprint_name":"Baseline sprint"}""", 4);
        Assert.False(okSprint, msgSprint);
        Assert.Equal(2, sprintTickets.GetProperty("totalCount").GetInt32());

        // Assignee filter by display name + pagination.
        var (okAssignee, msgAssignee, assigned) = await CallToolAsync(member, "list_tickets",
            """{"project_key":"FIXA","assignee_display_name":"owner","limit":1,"offset":1}""", 5);
        Assert.False(okAssignee, msgAssignee);
        Assert.Equal(2, assigned.GetProperty("totalCount").GetInt32());
        Assert.Equal(1, assigned.GetProperty("items").GetArrayLength());
        Assert.Equal("FIXA-2", assigned.GetProperty("items")[0].GetProperty("ticketRef").GetString());

        // 'mine' without project: only the caller's own tickets across accessible projects.
        var (okMine, msgMine, mine) = await CallToolAsync(member, "list_tickets", """{"mine":true}""", 6);
        Assert.False(okMine, msgMine);
        Assert.Equal(0, mine.GetProperty("totalCount").GetInt32()); // fixture tickets are assigned to owners
    }

    [Fact]
    public async Task Rest_search_endpoint_shares_the_same_capability()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var member = await McpClientAsync(factory, "member");

        // Close a ticket via the tool, then find it through the REST search endpoint.
        var (ok, msg, _) = await CallToolAsync(member, "close_ticket", """{"ticket_ref":"FIXA-2"}""", 2);
        Assert.False(ok, msg);

        using var api = factory.ClientFor("member");
        using var done = await api.GetAsync($"/api/projects/{BaselineFixture.SharedProjectId}/tickets?statusCategory=Done");
        Assert.Equal(HttpStatusCode.OK, done.StatusCode);
        using var payload = JsonDocument.Parse(await done.Content.ReadAsStringAsync());
        var tickets = payload.RootElement.EnumerateArray().ToList();
        Assert.Single(tickets);
        Assert.Equal("FIXA-2", tickets[0].GetProperty("ticketRef").GetString());
        Assert.Equal(1, int.Parse(done.Headers.GetValues("X-Total-Count").Single()));

        // Type filter and 'mine'.
        using var bugs = await api.GetAsync($"/api/projects/{BaselineFixture.SharedProjectId}/tickets?type=Bug");
        using var bugPayload = JsonDocument.Parse(await bugs.Content.ReadAsStringAsync());
        Assert.Equal(0, bugPayload.RootElement.GetArrayLength());

        using var mine = await api.GetAsync($"/api/projects/{BaselineFixture.SharedProjectId}/tickets?mine=true");
        using var minePayload = JsonDocument.Parse(await mine.Content.ReadAsStringAsync());
        Assert.Equal(0, minePayload.RootElement.GetArrayLength());

        // A non-member gets 403 from the endpoint.
        using var outsiderApi = factory.ClientFor("outsider");
        using var forbidden = await outsiderApi.GetAsync($"/api/projects/{BaselineFixture.SharedProjectId}/tickets");
        Assert.Equal(HttpStatusCode.Forbidden, forbidden.StatusCode);
    }
}
