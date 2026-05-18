using System.ComponentModel.DataAnnotations;

namespace Disciplaner.Application.DTOs.User;

public sealed record ChangeUserRoleRequest([Required] string Role);
