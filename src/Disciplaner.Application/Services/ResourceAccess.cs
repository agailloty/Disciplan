using Disciplaner.Application.Exceptions;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

internal static class ResourceAccess
{
    public static async Task Project(IUnitOfWork uow, Guid id, string user, CancellationToken ct, bool write = false, bool manage = false)
    {
        var project = await uow.Projects.GetByIdWithMembersAsync(id, ct) ?? throw new NotFoundException(nameof(Project), id);
        if (!(manage ? project.CanManage(user) : write ? project.CanWrite(user) : project.HasAccess(user)))
            throw new ForbiddenException();
    }

    public static async Task Board(IUnitOfWork uow, Guid id, string user, CancellationToken ct, bool write = false)
    {
        var board = await uow.Boards.GetByIdWithMembersAsync(id, ct) ?? throw new NotFoundException(nameof(Board), id);
        if (!(write ? board.CanWrite(user) : board.HasAccess(user))) throw new ForbiddenException();
    }

    public static async Task Ticket(IUnitOfWork uow, Guid id, string user, CancellationToken ct, bool write = false)
    {
        var ticket = await uow.Tickets.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Ticket), id);
        await Project(uow, ticket.ProjectId, user, ct, write);
    }

    public static async Task Card(IUnitOfWork uow, Guid id, string user, CancellationToken ct, bool write = false)
    {
        var card = await uow.Cards.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Card), id);
        var column = await uow.Columns.GetByIdAsync(card.ColumnId, ct) ?? throw new NotFoundException(nameof(Column), card.ColumnId);
        await Board(uow, column.BoardId, user, ct, write);
    }

    public static async Task Comment(IUnitOfWork uow, Guid id, string user, CancellationToken ct, bool write = false)
    {
        var comment = await uow.Comments.GetByIdAsync(id, ct) ?? throw new NotFoundException(nameof(Comment), id);
        if (comment.TicketId is Guid ticketId) await Ticket(uow, ticketId, user, ct, write);
        else if (comment.CardId is Guid cardId) await Card(uow, cardId, user, ct, write);
        else throw new ForbiddenException();
    }

    public static async Task Attachment(IUnitOfWork uow, Attachment attachment, string user, CancellationToken ct, bool write = false)
    {
        if (attachment.TicketId is Guid ticketId) await Ticket(uow, ticketId, user, ct, write);
        else if (attachment.CommentId is Guid commentId) await Comment(uow, commentId, user, ct, write);
        else if (attachment.BoardId is Guid boardId) await Board(uow, boardId, user, ct, write);
        else throw new ForbiddenException();
    }
}
