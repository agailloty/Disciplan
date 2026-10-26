using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

/// <summary>Smoke-test tool proving the /mcp endpoint is live and authenticated.</summary>
[McpServerToolType]
public static class PingTools
{
    [McpServerTool, Description("Returns 'pong'. Use it to check that the Disciplaner MCP connection works.")]
    public static string Ping() => "pong";
}
