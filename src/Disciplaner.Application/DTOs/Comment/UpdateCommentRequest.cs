using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;

namespace Disciplaner.Application.DTOs.Comment;

public sealed record UpdateCommentRequest(
    [Required, MaxLength(DomainConstraints.Comment.ContentMaxLength)]
    string Content
);
