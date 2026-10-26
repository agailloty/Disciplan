using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Disciplaner.Domain.Common;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Disciplaner.Tests;

/// <summary>
/// Lot 06 — server prompts exposed over /mcp. Synthetic fixtures only (D08).
/// </summary>
public class McpServerPromptsTests
{
    private const string InitializeRequest =
        """{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"disciplaner-tests","version":"1.0"}}}""";

    [Fact]
    public async Task Prompts_list_exposes_enrich_backlog_and_sprint_review()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        // Token
        using var api = factory.ClientFor("member");
        using var created = await api.PostAsync("/api/me/mcp-tokens",
            new StringContent("""{"name":"lot06","scopes":"read"}""", Encoding.UTF8, "application/json"));
        Assert.Equal(HttpStatusCode.Created, created.StatusCode);
        using var payload = JsonDocument.Parse(await created.Content.ReadAsStringAsync());
        var raw = payload.RootElement.GetProperty("token").GetString();
        Assert.StartsWith(McpTokenSecurity.RawPrefix, raw);

        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
            { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", raw);

        using var init = await RpcAsync(client, InitializeRequest);
        Assert.Equal(HttpStatusCode.OK, init.StatusCode);

        using var prompts = await RpcAsync(client, """{"jsonrpc":"2.0","id":2,"method":"prompts/list"}""");
        Assert.Equal(HttpStatusCode.OK, prompts.StatusCode);
        var body = await prompts.Content.ReadAsStringAsync();
        if ((prompts.Content.Headers.ContentType?.MediaType ?? "").Contains("text/event-stream"))
            body = body.Split('\n').FirstOrDefault(l => l.StartsWith("data:", StringComparison.Ordinal))?["data:".Length..].Trim() ?? body;
        using var document = JsonDocument.Parse(body);
        var list = document.RootElement.GetProperty("result").GetProperty("prompts").EnumerateArray()
            .ToDictionary(p => p.GetProperty("name").GetString());
        Assert.Contains("enrich-backlog", list.Keys);
        Assert.Contains("sprint-review", list.Keys);

        // enrich-backlog renders its instructions with the caller's arguments and
        // never creates anything by itself.
        using var get = await RpcAsync(client,
            """{"jsonrpc":"2.0","id":3,"method":"prompts/get","params":{"name":"enrich-backlog","arguments":{"project_key":"FIXA","objective":"A mobile offline mode"}}}""");
        Assert.Equal(HttpStatusCode.OK, get.StatusCode);
        var getBody = await get.Content.ReadAsStringAsync();
        if ((get.Content.Headers.ContentType?.MediaType ?? "").Contains("text/event-stream"))
            getBody = getBody.Split('\n').FirstOrDefault(l => l.StartsWith("data:", StringComparison.Ordinal))?["data:".Length..].Trim() ?? getBody;
        using var getDoc = JsonDocument.Parse(getBody);
        var messages = getDoc.RootElement.GetProperty("result").GetProperty("messages").EnumerateArray().ToList();
        var text = messages.Single().GetProperty("content").GetProperty("text").GetString() ?? "";
        Assert.Contains("FIXA", text);
        Assert.Contains("mobile offline mode", text);
        Assert.Contains("Do NOT create anything yet", text);
        Assert.Contains("create_tickets", text);
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
}
