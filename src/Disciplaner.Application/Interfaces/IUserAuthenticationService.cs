namespace Disciplaner.Application.Interfaces;

public interface IUserAuthenticationService
{
    Task<(bool Success, string? UserId, string? ErrorMessage)> ValidateCredentialsAsync(
        string email,
        string password,
        CancellationToken ct = default);
}
