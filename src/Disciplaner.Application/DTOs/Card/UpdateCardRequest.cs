using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.Card;

public sealed record UpdateCardRequest(
    [Required, StringLength(200, MinimumLength = 1)]
    string Title,

    [StringLength(2000)]
    string? Description,

    CardPriority Priority,

    DateTime? DueDate,

    string? AssignedToId = null
);
