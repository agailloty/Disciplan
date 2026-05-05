using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;

namespace Disciplaner.Application.DTOs.Label;

public sealed record CreateLabelRequest(
    [Required, MaxLength(DomainConstraints.Label.NameMaxLength)] string Name,
    [Required] string Color
);

public sealed record UpdateLabelRequest(
    [Required, MaxLength(DomainConstraints.Label.NameMaxLength)] string Name,
    [Required] string Color
);
