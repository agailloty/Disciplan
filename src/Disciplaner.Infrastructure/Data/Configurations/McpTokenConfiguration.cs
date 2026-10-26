using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class McpTokenConfiguration : IEntityTypeConfiguration<McpToken>
{
    public void Configure(EntityTypeBuilder<McpToken> builder)
    {
        builder.ToTable("McpTokens");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Id)
            .ValueGeneratedNever();

        builder.Property(t => t.UserId)
            .IsRequired()
            .HasMaxLength(450); // AspNetUsers.Id length

        builder.Property(t => t.Name)
            .IsRequired()
            .HasMaxLength(DomainConstraints.McpToken.NameMaxLength);

        builder.Property(t => t.Scopes)
            .IsRequired()
            .HasMaxLength(DomainConstraints.McpToken.ScopesMaxLength);

        builder.Property(t => t.TokenHash)
            .IsRequired()
            .HasMaxLength(DomainConstraints.McpToken.TokenHashLength);

        builder.Property(t => t.CreatedAt)
            .IsRequired();

        // Fast lookup of a token by its salted hash (single indexed query per MCP request)
        builder.HasIndex(t => t.TokenHash).IsUnique();
        builder.HasIndex(t => t.UserId);
    }
}
