using System.ComponentModel.DataAnnotations;
using Disciplaner.Domain.Common;
using Disciplaner.Domain.Enums;

namespace Disciplaner.Application.DTOs.TicketStatus;

public sealed record CreateTicketStatusRequest(
    [Required, MaxLength(DomainConstraints.TicketStatus.NameMaxLength)]
    string Name,
    StatusCategory Category,
    [Required] string Color
);

public sealed record UpdateTicketStatusRequest(
    [Required, MaxLength(DomainConstraints.TicketStatus.NameMaxLength)]
    string Name,
    StatusCategory Category,
    [Required] string Color
);
