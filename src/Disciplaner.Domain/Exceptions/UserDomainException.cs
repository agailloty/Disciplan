namespace Disciplaner.Domain.Exceptions;

public sealed class UserDomainException : DomainException
{
    public UserDomainException(string message) : base(message) { }

    public static UserDomainException EmptyUserName()
        => new("UserName cannot be empty.");

    public static UserDomainException EmptyEmail()
        => new("Email cannot be empty.");

    public static UserDomainException DisplayNameTooLong(int maxLength)
        => new($"Display name cannot exceed {maxLength} characters.");

    public static UserDomainException AccountInactive()
        => new("This user account is inactive.");
}
