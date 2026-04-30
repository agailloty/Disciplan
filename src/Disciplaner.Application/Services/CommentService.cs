using Disciplaner.Application.DTOs.Comment;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;

namespace Disciplaner.Application.Services;

public sealed class CommentService : ICommentService
{
    private readonly IUnitOfWork _uow;

    public CommentService(IUnitOfWork uow) => _uow = uow;

    public async Task<IReadOnlyList<CommentDto>> GetByCardAsync(
        Guid cardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureCardAccessAsync(cardId, requestingUserId, cancellationToken);

        var comments = await _uow.Comments.GetByCardIdAsync(cardId, cancellationToken);
        return await ToDtosAsync(comments, cancellationToken);
    }

    public async Task<CommentDto> CreateAsync(
        Guid cardId, string authorId, CreateCommentRequest request,
        CancellationToken cancellationToken = default)
    {
        var card = await EnsureCardAccessAsync(cardId, authorId, cancellationToken);

        var comment = Comment.Create(request.Content, authorId, card);
        await _uow.Comments.AddAsync(comment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(comment, cancellationToken);
    }

    public async Task<IReadOnlyList<CommentDto>> GetByTicketAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectAccessAsync(ticket.ProjectId, requestingUserId, cancellationToken);
        var comments = await _uow.Comments.GetByTicketIdAsync(ticketId, cancellationToken);
        return await ToDtosAsync(comments, cancellationToken);
    }

    public async Task<CommentDto> CreateForTicketAsync(
        Guid ticketId, string authorId, CreateCommentRequest request,
        CancellationToken cancellationToken = default)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, cancellationToken)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectAccessAsync(ticket.ProjectId, authorId, cancellationToken);

        var comment = Comment.CreateForTicket(request.Content, authorId, ticketId);
        await _uow.Comments.AddAsync(comment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
        return await ToDtoAsync(comment, cancellationToken);
}

    public async Task<CommentDto> UpdateAsync(
        Guid commentId, string requestingUserId, UpdateCommentRequest request,
        CancellationToken cancellationToken = default)
    {
        var comment = await _uow.Comments.GetByIdAsync(commentId, cancellationToken)
            ?? throw new NotFoundException(nameof(Comment), commentId);

        if (comment.AuthorId != requestingUserId)
            throw new UnauthorizedAccessException("Only the author can edit a comment.");

        comment.SetContent(request.Content);
        await _uow.Comments.UpdateAsync(comment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(comment, cancellationToken);
    }

    public async Task DeleteAsync(
        Guid commentId, string requestingUserId, bool isAdmin,
        CancellationToken cancellationToken = default)
    {
        var comment = await _uow.Comments.GetByIdAsync(commentId, cancellationToken)
            ?? throw new NotFoundException(nameof(Comment), commentId);

        if (!isAdmin && comment.AuthorId != requestingUserId)
            throw new UnauthorizedAccessException("Only the author or an admin can delete a comment.");

        await _uow.Comments.DeleteAsync(comment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task EnsureProjectAccessAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        if (project.OwnerId != userId)
            throw new UnauthorizedAccessException("Access denied.");
    }

    private async Task<Card> EnsureCardAccessAsync(
        Guid cardId, string userId, CancellationToken cancellationToken)
    {
        var card = await _uow.Cards.GetByIdAsync(cardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Card), cardId);

        var column = await _uow.Columns.GetByIdAsync(card.ColumnId, cancellationToken)
            ?? throw new NotFoundException(nameof(Column), card.ColumnId);

        var board = await _uow.Boards.GetByIdAsync(column.BoardId, cancellationToken)
            ?? throw new NotFoundException(nameof(Board), column.BoardId);

        if (board.OwnerId != userId)
            throw new UnauthorizedAccessException("Access denied.");

        return card;
    }

    private async Task<CommentDto> ToDtoAsync(Comment comment, CancellationToken cancellationToken)
    {
        var author = await _uow.Users.GetByIdAsync(comment.AuthorId, cancellationToken);
        var authorName = author?.DisplayName ?? author?.Email ?? comment.AuthorId;
        return ToDto(comment, authorName);
    }

    private async Task<IReadOnlyList<CommentDto>> ToDtosAsync(
        IReadOnlyList<Comment> comments, CancellationToken cancellationToken)
    {
        if (comments.Count == 0) return [];

        // Batch-load distinct authors
        var authorIds = comments.Select(c => c.AuthorId).Distinct().ToList();
        var authors = new Dictionary<string, string>(authorIds.Count);
        foreach (var id in authorIds)
        {
            var user = await _uow.Users.GetByIdAsync(id, cancellationToken);
            authors[id] = user?.DisplayName ?? user?.Email ?? id;
        }

        return comments
            .OrderBy(c => c.CreatedAt)
            .Select(c => ToDto(c, authors.GetValueOrDefault(c.AuthorId, c.AuthorId)))
            .ToList()
            .AsReadOnly();
    }

    private static CommentDto ToDto(Comment c, string authorName) => new(
        c.Id, c.CardId, c.AuthorId, authorName, c.Content, c.CreatedAt, c.UpdatedAt);
}
