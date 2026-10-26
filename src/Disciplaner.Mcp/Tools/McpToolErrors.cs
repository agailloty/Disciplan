using Disciplaner.Application.Exceptions;
using Disciplaner.Domain.Exceptions;
using ModelContextProtocol;

namespace Disciplaner.Mcp.Tools;

/// <summary>
/// Translates application exceptions into actionable MCP tool errors (M07):
/// the LLM must be able to self-correct from the message alone.
/// </summary>
public static class McpToolErrors
{
    public static async Task<T> RunAsync<T>(Func<Task<T>> action)
    {
        try
        {
            return await action();
        }
        catch (McpException)
        {
            throw; // already an actionable tool error
        }
        catch (NotFoundException ex)
        {
            throw new McpException($"{ex.Message} Use list_projects or list_sprints to see what is available to you.");
        }
        catch (ForbiddenException ex)
        {
            throw new McpException(
                $"You don't have permission for this operation ({ex.Message}) " +
                "This depends on your project role (Guest is read-only) or the token scope.");
        }
        catch (DomainException ex)
        {
            throw new McpException(ex.Message);
        }
        catch (ArgumentException ex)
        {
            throw new McpException(ex.Message);
        }
    }

    public static async Task RunAsync(Func<Task> action)
        => await RunAsync<object?>(async () => { await action(); return null; });
}
