using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;

namespace Disciplaner.Application.DTOs.Sprint;

public sealed record CreateSprintRequest(
    [Required, MaxLength(DomainConstraints.Sprint.NameMaxLength)]
    string Name,
    [MaxLength(DomainConstraints.Sprint.GoalMaxLength)]
    string? Goal
);

public sealed record UpdateSprintRequest(
    [Required, MaxLength(DomainConstraints.Sprint.NameMaxLength)]
    string Name,
    [MaxLength(DomainConstraints.Sprint.GoalMaxLength)]
    string? Goal,
    DateTime? StartDate,
    DateTime? EndDate
);

public sealed record StartSprintRequest(DateTime StartDate, DateTime EndDate);
