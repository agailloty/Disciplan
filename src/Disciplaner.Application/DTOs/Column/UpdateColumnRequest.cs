using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Column;

public sealed record UpdateColumnRequest(
    [Required, StringLength(50, MinimumLength = 1)]
    string Name
);
