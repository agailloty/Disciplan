using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class McpOAuthTokenConfiguration : IEntityTypeConfiguration<McpOAuthToken>
{
    public void Configure(EntityTypeBuilder<McpOAuthToken> builder)
    {
        builder.HasKey(t => t.Id);

        builder.Property(t => t.ClientId)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(t => t.UserId)
            .IsRequired()
            .HasMaxLength(450);

        builder.Property(t => t.Scope)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(t => t.AccessTokenHash)
            .IsRequired()
            .HasMaxLength(128);

        builder.HasIndex(t => t.AccessTokenHash)
            .IsUnique();

        builder.Property(t => t.RefreshTokenHash)
            .HasMaxLength(128);

        builder.HasIndex(t => t.RefreshTokenHash);

        builder.HasIndex(t => t.UserId);
    }
}
