using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class LabelConfiguration : IEntityTypeConfiguration<Label>
{
    public void Configure(EntityTypeBuilder<Label> builder)
    {
        builder.ToTable("Labels");

        builder.HasKey(l => l.Id);

        builder.Property(l => l.Id).ValueGeneratedNever();

        builder.Property(l => l.Name)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Label.NameMaxLength);

        builder.Property(l => l.Color)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Label.ColorMaxLength);

        builder.Property(l => l.CreatedAt).IsRequired();

        // Many-to-many: Label ↔ Ticket
        builder.HasMany(l => l.Tickets)
            .WithMany(t => t.Labels)
            .UsingEntity(j => j.ToTable("LabelTickets"));

        // Many-to-many: Label ↔ Board
        builder.HasMany(l => l.Boards)
            .WithMany(b => b.Labels)
            .UsingEntity(j => j.ToTable("LabelBoards"));
    }
}
