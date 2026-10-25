using Disciplaner.Application.Interfaces;
using Disciplaner.Mcp.Resolution;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace Disciplaner.Mcp.Tools;

[McpServerToolType]
public sealed class TicketsTools
{
    private readonly McpToolContext _context;
    private readonly McpReferenceResolver _resolver;
    private readonly ITicketService _tickets;
    private readonly ICommentService _comments;

    public TicketsTools(
        McpToolContext context,
        McpReferenceResolver resolver,
        ITicketService tickets,
        ICommentService comments)
    {
        _context = context;
        _resolver = resolver;
        _tickets = tickets;
        _comments = comments;
    }

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Returns one ticket's full details: description, status (with its category), type, priority, story points, due date, sprint, assignee, reporter and labels. Identify the ticket by its reference 'KEY-number' (e.g. 'DISC-42', case-insensitive) or by GUID id.")]
    public async Task<Projections.McpTicketDetail> GetTicket(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string? ticket_ref = null,
        [Description("Ticket GUID id (alternative to ticket_ref).")] string? ticket_id = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, ticket_id, _context.UserId, ct);
            return Projections.ToTicketDetail(ticket);
        });

    [McpServerTool(ReadOnly = true, UseStructuredContent = true)]
    [Description("Lists the comments of a ticket, oldest first, with author and content.")]
    public async Task<Projections.McpPage<Projections.McpComment>> ListComments(
        [Description("Ticket reference, e.g. 'DISC-42'. Case-insensitive.")] string ticket_ref,
        [Description("Maximum number of comments to return (1-100, default 50).")] int? limit = null,
        [Description("Number of comments to skip for pagination.")] int? offset = null,
        CancellationToken ct = default)
        => await McpToolErrors.RunAsync(async () =>
        {
            _context.EnsureReadScope();
            var (take, skip) = _context.NormalizePaging(limit, offset);
            var ticket = await _resolver.ResolveTicketAsync(ticket_ref, null, _context.UserId, ct);
            var comments = await _comments.GetByTicketAsync(ticket.Id, _context.UserId, ct);
            return Projections.Page(comments.Select(Projections.ToComment).ToList(), take, skip);
        });
}
