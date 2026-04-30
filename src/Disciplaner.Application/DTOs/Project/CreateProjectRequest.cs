using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;

namespace Disciplaner.Application.DTOs.Project;

public sealed record CreateProjectRequest(
    [Required, MaxLength(DomainConstraints.Project.NameMaxLength)]
    string Name,
    [MaxLength(DomainConstraints.Project.DescriptionMaxLength)]
    string? Description,
    [Required, MaxLength(DomainConstraints.Project.KeyMaxLength)]
    string Key
);
