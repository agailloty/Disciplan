using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Repositories;

internal sealed class AttachmentRepository : IAttachmentRepository
{
    private readonly ApplicationDbContext _context;

    public AttachmentRepository(ApplicationDbContext context) => _context = context;

    public async Task<Attachment?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.Attachments.FindAsync([id], cancellationToken);

    public async Task<IReadOnlyList<Attachment>> GetByTicketIdAsync(
        Guid ticketId, CancellationToken cancellationToken = default)
        => await _context.Attachments
            .Where(a => a.TicketId == ticketId)
            .OrderBy(a => a.UploadedAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Attachment>> GetByCommentIdAsync(
        Guid commentId, CancellationToken cancellationToken = default)
        => await _context.Attachments
            .Where(a => a.CommentId == commentId)
            .OrderBy(a => a.UploadedAt)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<Attachment>> GetByBoardIdAsync(
        Guid boardId, CancellationToken cancellationToken = default)
        => await _context.Attachments
            .Where(a => a.BoardId == boardId)
            .OrderBy(a => a.UploadedAt)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Attachment attachment, CancellationToken cancellationToken = default)
        => await _context.Attachments.AddAsync(attachment, cancellationToken);

    public Task DeleteAsync(Attachment attachment, CancellationToken cancellationToken = default)
    {
        _context.Attachments.Remove(attachment);
        return Task.CompletedTask;
    }
}
