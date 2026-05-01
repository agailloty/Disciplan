using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.User;

public sealed record UpdateDisplayNameRequest(
    [Required, MaxLength(100)] string DisplayName
);
