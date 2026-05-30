using Disciplaner.Application.DTOs.Attachment;
using Disciplaner.Application.Exceptions;
using Disciplaner.Application.Interfaces;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Microsoft.Extensions.Options;

namespace Disciplaner.Application.Services;

public sealed class AttachmentService : IAttachmentService
{
    private readonly IUnitOfWork _uow;
    private readonly IFileStorageService _storage;
    private readonly FileStorageOptions _options;

    public AttachmentService(IUnitOfWork uow, IFileStorageService storage, IOptions<FileStorageOptions> options)
    {
        _uow = uow;
        _storage = storage;
        _options = options.Value;
    }

    // ── Queries ───────────────────────────────────────────────────────────────

    public async Task<IReadOnlyList<AttachmentDto>> GetByTicketAsync(
        Guid ticketId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureTicketAccessAsync(ticketId, requestingUserId, cancellationToken);
        var attachments = await _uow.Attachments.GetByTicketIdAsync(ticketId, cancellationToken);
        return await ToDtosAsync(attachments, cancellationToken);
    }

    public async Task<IReadOnlyList<AttachmentDto>> GetByCommentAsync(
        Guid commentId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureCommentAccessAsync(commentId, requestingUserId, cancellationToken);
        var attachments = await _uow.Attachments.GetByCommentIdAsync(commentId, cancellationToken);
        return await ToDtosAsync(attachments, cancellationToken);
    }

    public async Task<IReadOnlyList<AttachmentDto>> GetByBoardAsync(
        Guid boardId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        await EnsureBoardAccessAsync(boardId, requestingUserId, cancellationToken);
        var attachments = await _uow.Attachments.GetByBoardIdAsync(boardId, cancellationToken);
        return await ToDtosAsync(attachments, cancellationToken);
    }

    // ── Uploads ───────────────────────────────────────────────────────────────

    public async Task<AttachmentDto> UploadForTicketAsync(
        Guid ticketId, string uploadedById, UploadFileRequest file,
        CancellationToken cancellationToken = default)
    {
        await EnsureTicketAccessAsync(ticketId, uploadedById, cancellationToken);
        ValidateFile(file);

        var storagePath = await _storage.SaveAsync(file.Content, file.OriginalFileName, "tickets", cancellationToken);
        var attachment = Attachment.ForTicket(
            file.OriginalFileName, storagePath, file.ContentType, file.SizeBytes, uploadedById, ticketId);

        await _uow.Attachments.AddAsync(attachment, cancellationToken);

        var actor = await _uow.Users.GetByIdAsync(uploadedById, cancellationToken);
        var actorName = actor?.DisplayName ?? actor?.Email ?? uploadedById;
        await _uow.TicketHistory.AddAsync(
            TicketHistory.Record(ticketId, "attachment_added", uploadedById, actorName,
                oldValue: attachment.Id.ToString(), newValue: file.OriginalFileName),
            cancellationToken);

        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(attachment, cancellationToken);
    }

    public async Task<AttachmentDto> UploadForCommentAsync(
        Guid commentId, string uploadedById, UploadFileRequest file,
        CancellationToken cancellationToken = default)
    {
        await EnsureCommentAccessAsync(commentId, uploadedById, cancellationToken);
        ValidateFile(file);

        var storagePath = await _storage.SaveAsync(file.Content, file.OriginalFileName, "comments", cancellationToken);
        var attachment = Attachment.ForComment(
            file.OriginalFileName, storagePath, file.ContentType, file.SizeBytes, uploadedById, commentId);

        await _uow.Attachments.AddAsync(attachment, cancellationToken);

        var comment = await _uow.Comments.GetByIdAsync(commentId, cancellationToken);
        if (comment?.TicketId.HasValue == true)
        {
            var actor = await _uow.Users.GetByIdAsync(uploadedById, cancellationToken);
            var actorName = actor?.DisplayName ?? actor?.Email ?? uploadedById;
            await _uow.TicketHistory.AddAsync(
                TicketHistory.Record(comment.TicketId.Value, "attachment_added", uploadedById, actorName,
                    oldValue: attachment.Id.ToString(), newValue: file.OriginalFileName),
                cancellationToken);
        }

        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(attachment, cancellationToken);
    }

    public async Task<AttachmentDto> UploadForBoardAsync(
        Guid boardId, string uploadedById, UploadFileRequest file,
        CancellationToken cancellationToken = default)
    {
        await EnsureBoardAccessAsync(boardId, uploadedById, cancellationToken);
        ValidateFile(file);

        var storagePath = await _storage.SaveAsync(file.Content, file.OriginalFileName, "boards", cancellationToken);
        var attachment = Attachment.ForBoard(
            file.OriginalFileName, storagePath, file.ContentType, file.SizeBytes, uploadedById, boardId);

        await _uow.Attachments.AddAsync(attachment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);

        return await ToDtoAsync(attachment, cancellationToken);
    }

    // ── Download ──────────────────────────────────────────────────────────────

    public async Task<AttachmentFileInfo> GetDownloadInfoAsync(
        Guid attachmentId, string requestingUserId, CancellationToken cancellationToken = default)
    {
        var attachment = await _uow.Attachments.GetByIdAsync(attachmentId, cancellationToken)
            ?? throw new NotFoundException(nameof(Attachment), attachmentId);

        if (attachment.TicketId.HasValue)
            await EnsureTicketAccessAsync(attachment.TicketId.Value, requestingUserId, cancellationToken);
        else if (attachment.CommentId.HasValue)
            await EnsureCommentAccessAsync(attachment.CommentId.Value, requestingUserId, cancellationToken);
        else if (attachment.BoardId.HasValue)
            await EnsureBoardAccessAsync(attachment.BoardId.Value, requestingUserId, cancellationToken);

        var absolutePath = _storage.GetAbsolutePath(attachment.StoragePath);
        return new AttachmentFileInfo(absolutePath, attachment.ContentType, attachment.FileName);
    }

    // ── Delete ────────────────────────────────────────────────────────────────

    public async Task DeleteAsync(
        Guid attachmentId, string requestingUserId, bool isAdmin,
        CancellationToken cancellationToken = default)
    {
        var attachment = await _uow.Attachments.GetByIdAsync(attachmentId, cancellationToken)
            ?? throw new NotFoundException(nameof(Attachment), attachmentId);

        if (!isAdmin && attachment.UploadedById != requestingUserId)
            throw new ForbiddenException($"User '{requestingUserId}' cannot delete this attachment.");

        await _storage.DeleteAsync(attachment.StoragePath, cancellationToken);
        await _uow.Attachments.DeleteAsync(attachment, cancellationToken);
        await _uow.SaveChangesAsync(cancellationToken);
    }

    // ── Validation ────────────────────────────────────────────────────────────

    private void ValidateFile(UploadFileRequest file)
    {
        if (file.SizeBytes <= 0)
            throw new ArgumentException("File is empty.");

        if (file.SizeBytes > _options.MaxFileSizeBytes)
            throw new ArgumentException(
                $"File exceeds the maximum allowed size of {_options.MaxFileSizeBytes / 1024 / 1024} MB.");

        if (!_options.AllowedContentTypes.Contains(file.ContentType, StringComparer.OrdinalIgnoreCase))
            throw new ArgumentException($"File type '{file.ContentType}' is not allowed.");
    }

    // ── Access helpers ────────────────────────────────────────────────────────

    private async Task EnsureTicketAccessAsync(Guid ticketId, string userId, CancellationToken ct)
    {
        var ticket = await _uow.Tickets.GetByIdAsync(ticketId, ct)
            ?? throw new NotFoundException(nameof(Ticket), ticketId);
        await EnsureProjectAccessAsync(ticket.ProjectId, userId, ct);
    }

    private async Task EnsureProjectAccessAsync(Guid projectId, string userId, CancellationToken ct)
    {
        var project = await _uow.Projects.GetByIdWithMembersAsync(projectId, ct)
            ?? throw new NotFoundException(nameof(Project), projectId);
        if (!project.HasAccess(userId))
            throw new ForbiddenException($"User '{userId}' does not have access to this resource.");
    }

    private async Task EnsureCommentAccessAsync(Guid commentId, string userId, CancellationToken ct)
    {
        var comment = await _uow.Comments.GetByIdAsync(commentId, ct)
            ?? throw new NotFoundException(nameof(Comment), commentId);

        if (comment.TicketId.HasValue)
        {
            await EnsureTicketAccessAsync(comment.TicketId.Value, userId, ct);
        }
        else if (comment.CardId.HasValue)
        {
            var card = await _uow.Cards.GetByIdAsync(comment.CardId.Value, ct)
                ?? throw new NotFoundException(nameof(Card), comment.CardId.Value);
            var column = await _uow.Columns.GetByIdAsync(card.ColumnId, ct)
                ?? throw new NotFoundException(nameof(Column), card.ColumnId);
            await EnsureBoardAccessAsync(column.BoardId, userId, ct);
        }
    }

    private async Task EnsureBoardAccessAsync(Guid boardId, string userId, CancellationToken ct)
    {
        var board = await _uow.Boards.GetByIdWithMembersAsync(boardId, ct)
            ?? throw new NotFoundException(nameof(Board), boardId);
        if (!board.HasAccess(userId))
            throw new ForbiddenException($"User '{userId}' does not have access to this resource.");
    }

    // ── Mapping ───────────────────────────────────────────────────────────────

    private async Task<AttachmentDto> ToDtoAsync(Attachment attachment, CancellationToken ct)
    {
        var uploader = await _uow.Users.GetByIdAsync(attachment.UploadedById, ct);
        var uploaderName = uploader?.DisplayName ?? uploader?.Email ?? attachment.UploadedById;
        return ToDto(attachment, uploaderName);
    }

    private async Task<IReadOnlyList<AttachmentDto>> ToDtosAsync(
        IReadOnlyList<Attachment> attachments, CancellationToken ct)
    {
        if (attachments.Count == 0) return [];

        var uploaderCache = new Dictionary<string, string>(attachments.Count);
        var result = new List<AttachmentDto>(attachments.Count);

        foreach (var attachment in attachments)
        {
            if (!uploaderCache.TryGetValue(attachment.UploadedById, out var uploaderName))
            {
                var uploader = await _uow.Users.GetByIdAsync(attachment.UploadedById, ct);
                uploaderName = uploader?.DisplayName ?? uploader?.Email ?? attachment.UploadedById;
                uploaderCache[attachment.UploadedById] = uploaderName;
            }

            result.Add(ToDto(attachment, uploaderName));
        }

        return result.AsReadOnly();
    }

    private static AttachmentDto ToDto(Attachment a, string uploaderName) => new(
        a.Id, a.FileName, a.ContentType, a.SizeBytes,
        a.UploadedById, uploaderName, a.UploadedAt,
        a.TicketId, a.CommentId, a.BoardId);
}
