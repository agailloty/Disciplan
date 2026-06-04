using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class CalendarTokenConfiguration : IEntityTypeConfiguration<CalendarToken>
{
    public void Configure(EntityTypeBuilder<CalendarToken> builder)
    {
        builder.ToTable("CalendarTokens");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Id)
            .ValueGeneratedNever();

        builder.Property(t => t.UserId)
            .IsRequired()
            .HasMaxLength(450); // AspNetUsers.Id length

        builder.Property(t => t.Token)
            .IsRequired()
            .HasMaxLength(DomainConstraints.CalendarToken.TokenLength);

        builder.Property(t => t.CreatedAt)
            .IsRequired();

        builder.Property(t => t.LastAccessedAt);

        // One token per user
        builder.HasIndex(t => t.UserId).IsUnique();

        // Fast lookup by opaque token value
        builder.HasIndex(t => t.Token).IsUnique();
    }
}
