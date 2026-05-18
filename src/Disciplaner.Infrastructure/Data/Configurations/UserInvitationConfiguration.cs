using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class UserInvitationConfiguration : IEntityTypeConfiguration<UserInvitation>
{
    public void Configure(EntityTypeBuilder<UserInvitation> builder)
    {
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Token).IsRequired().HasMaxLength(64);
        builder.HasIndex(x => x.Token).IsUnique();
        builder.Property(x => x.Email).HasMaxLength(256);
        builder.Property(x => x.InvitedByUserId).IsRequired().HasMaxLength(450);
    }
}
