using Disciplaner.Domain.Common;
using Disciplaner.Domain.Exceptions;

namespace Disciplaner.Domain.Entities;

/// <summary>
/// Domain user entity. Infrastructure maps this to ApplicationUser (IdentityUser).
/// </summary>
public class User
{
    private readonly List<Board> _boards = [];

    public string Id { get; private init; } = string.Empty;
    public string UserName { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string DisplayName { get; private set; } = string.Empty;
    public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
    public bool IsActive { get; private set; } = true;

    public IReadOnlyCollection<Board> Boards => _boards.AsReadOnly();

    protected User() { }

    public User(string id, string userName, string email, string displayName)
    {
        if (string.IsNullOrWhiteSpace(id))
            throw UserDomainException.EmptyUserName();

        if (string.IsNullOrWhiteSpace(userName))
            throw UserDomainException.EmptyUserName();

        if (string.IsNullOrWhiteSpace(email))
            throw UserDomainException.EmptyEmail();

        Id = id;
        UserName = userName.Trim();
        Email = email.Trim();
        SetDisplayName(string.IsNullOrWhiteSpace(displayName) ? userName : displayName);
    }

    public void UpdateDisplayName(string displayName)
    {
        SetDisplayName(displayName);
    }

    public void Deactivate() => IsActive = false;

    public void Activate() => IsActive = true;

    private void SetDisplayName(string displayName)
    {
        if (string.IsNullOrWhiteSpace(displayName))
            throw new UserDomainException("Display name cannot be empty.");

        if (displayName.Length > DomainConstraints.User.DisplayNameMaxLength)
            throw UserDomainException.DisplayNameTooLong(DomainConstraints.User.DisplayNameMaxLength);

        DisplayName = displayName.Trim();
    }
}
