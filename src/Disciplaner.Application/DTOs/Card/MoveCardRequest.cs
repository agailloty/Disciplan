using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Card;

public sealed record MoveCardRequest(
    [Required]
    Guid TargetColumnId,

    [Range(0, int.MaxValue)]
    int TargetPosition
);
