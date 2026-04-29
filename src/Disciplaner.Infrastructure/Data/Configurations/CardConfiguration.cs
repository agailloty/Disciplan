using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class CardConfiguration : IEntityTypeConfiguration<Card>
{
    public void Configure(EntityTypeBuilder<Card> builder)
    {
        builder.ToTable("Cards");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .ValueGeneratedNever();

        builder.Property(c => c.Title)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Card.TitleMaxLength);

        builder.Property(c => c.Description)
            .HasMaxLength(DomainConstraints.Card.DescriptionMaxLength);

        builder.Property(c => c.Order)
            .IsRequired();

        builder.Property(c => c.Priority)
            .IsRequired()
            .HasConversion<string>(); // store as string for readability

        builder.Property(c => c.CreatedAt)
            .IsRequired();

        builder.Property(c => c.UpdatedAt);

        builder.Property(c => c.DueDate);

        builder.Property(c => c.ColumnId)
            .IsRequired();

        // Index for sorted queries per column
        builder.HasIndex(c => new { c.ColumnId, c.Order });
    }
}
