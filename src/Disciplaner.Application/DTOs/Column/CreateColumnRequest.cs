using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Column;

public sealed record CreateColumnRequest(
    [Required, StringLength(50, MinimumLength = 1)]
    string Name
);
