using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class McpOAuthClientConfiguration : IEntityTypeConfiguration<McpOAuthClient>
{
    public void Configure(EntityTypeBuilder<McpOAuthClient> builder)
    {
        builder.HasKey(c => c.Id);

        builder.Property(c => c.ClientId)
            .IsRequired()
            .HasMaxLength(100);

        builder.HasIndex(c => c.ClientId)
            .IsUnique();

        builder.Property(c => c.ClientName)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.ClientSecretHash)
            .HasMaxLength(128);

        builder.Property(c => c.RedirectUrisJson)
            .IsRequired();

        builder.Property(c => c.GrantTypesJson)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(c => c.ResponseTypesJson)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.TokenEndpointAuthMethod)
            .IsRequired()
            .HasMaxLength(50);
    }
}
