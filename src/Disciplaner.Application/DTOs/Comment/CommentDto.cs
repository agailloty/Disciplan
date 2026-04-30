namespace Disciplaner.Application.DTOs.Comment;

public sealed record CommentDto(
    Guid Id,
    Guid? CardId,
    string AuthorId,
    string AuthorName,
    string Content,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);
