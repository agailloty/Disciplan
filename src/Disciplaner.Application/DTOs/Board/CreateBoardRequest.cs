using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Board;

public sealed record CreateBoardRequest(
    [Required, StringLength(100, MinimumLength = 1)]
    string Name,

    [StringLength(500)]
    string? Description
);
