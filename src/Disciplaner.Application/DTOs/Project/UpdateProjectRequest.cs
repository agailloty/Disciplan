using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;

namespace Disciplaner.Application.DTOs.Project;

public sealed record UpdateProjectRequest(
    [Required, MaxLength(DomainConstraints.Project.NameMaxLength)]
    string Name,
    [MaxLength(DomainConstraints.Project.DescriptionMaxLength)]
    string? Description
);
