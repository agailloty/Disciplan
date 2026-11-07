using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class McpOAuthAuthorizationCodeConfiguration : IEntityTypeConfiguration<McpOAuthAuthorizationCode>
{
    public void Configure(EntityTypeBuilder<McpOAuthAuthorizationCode> builder)
    {
        builder.HasKey(c => c.Id);

        builder.Property(c => c.CodeHash)
            .IsRequired()
            .HasMaxLength(128);

        builder.HasIndex(c => c.CodeHash)
            .IsUnique();

        builder.Property(c => c.ClientId)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.UserId)
            .IsRequired()
            .HasMaxLength(450);

        builder.Property(c => c.RedirectUri)
            .IsRequired()
            .HasMaxLength(2000);

        builder.Property(c => c.Scope)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(c => c.CodeChallenge)
            .IsRequired()
            .HasMaxLength(256);

        builder.Property(c => c.CodeChallengeMethod)
            .IsRequired()
            .HasMaxLength(20);
    }
}
