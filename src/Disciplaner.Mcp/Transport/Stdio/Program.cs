using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Client;
using ModelContextProtocol.Server;

namespace Disciplaner.Mcp.Transport.Stdio;

/// <summary>
/// Local stdio façade for the Disciplaner MCP connector (M05): connects to a running
/// Disciplaner server over its Streamable HTTP /mcp endpoint with a personal access
/// token, then mirrors the exact same tool definitions over stdio for desktop clients
/// (Claude Desktop, Cursor, ...). No tool is reimplemented: definitions are fetched
/// from the server and calls are relayed.
/// Configuration: DISCIPLAN_URL (server base URL) and DISCIPLAN_PAT (personal access token).
/// </summary>
public static class StdioMcpProxy
{
    public static async Task<int> RunAsync()
    {
        var url = Environment.GetEnvironmentVariable("DISCIPLAN_URL");
        var pat = Environment.GetEnvironmentVariable("DISCIPLAN_PAT");

        if (string.IsNullOrWhiteSpace(url) || string.IsNullOrWhiteSpace(pat))
        {
            await Console.Error.WriteLineAsync(
                "disciplaner-mcp: set DISCIPLAN_URL (e.g. https://disciplan.example.com) and DISCIPLAN_PAT (a personal access token created in Disciplaner).");
            return 2;
        }

        await using var client = await McpClient.CreateAsync(new HttpClientTransport(new HttpClientTransportOptions
        {
            Name = "Disciplaner",
            Endpoint = new Uri(url.TrimEnd('/') + "/mcp"),
            AdditionalHeaders = new Dictionary<string, string>
            {
                ["Authorization"] = "Bearer " + pat
            }
        }));

        // Mirror the server's own tool definitions — zero duplication, always in sync.
        var remoteTools = await client.ListToolsAsync();

        var builder = Host.CreateApplicationBuilder();
        // stdio transport: logs must never go to stdout.
        builder.Logging.ClearProviders();
        builder.Logging.AddConsole(options => options.LogToStandardErrorThreshold = LogLevel.Trace);

        builder.Services
            .AddMcpServer(options => options.ServerInstructions =
                "Disciplaner project management, connected through the local disciplaner-mcp proxy.")
            .WithStdioServerTransport()
            .WithTools(remoteTools.Select(t => McpServerTool.Create(t)).ToList());

        await builder.Build().RunAsync();
        return 0;
    }
}

public static class Program
{
    public static async Task<int> Main(string[] args)
    {
        if (args.Contains("--stdio"))
            return await StdioMcpProxy.RunAsync();

        await Console.Error.WriteLineAsync(
            "disciplaner-mcp — local stdio proxy for the Disciplaner MCP connector.\n" +
            "Usage: disciplaner-mcp --stdio   (with DISCIPLAN_URL and DISCIPLAN_PAT in the environment)");
        return 2;
    }
}
