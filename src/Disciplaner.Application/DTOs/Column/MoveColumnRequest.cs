using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.Column;

public sealed record MoveColumnRequest(
    [Range(0, int.MaxValue)]
    int TargetPosition
);
