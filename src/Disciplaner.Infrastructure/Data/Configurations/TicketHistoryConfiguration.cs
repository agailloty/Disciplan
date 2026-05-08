using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class TicketHistoryConfiguration : IEntityTypeConfiguration<TicketHistory>
{
    public void Configure(EntityTypeBuilder<TicketHistory> builder)
    {
        builder.ToTable("TicketHistories");
        builder.HasKey(h => h.Id);
        builder.Property(h => h.Id).ValueGeneratedNever();

        builder.Property(h => h.Kind).IsRequired().HasMaxLength(60);
        builder.Property(h => h.OldValue).HasMaxLength(500);
        builder.Property(h => h.NewValue).HasMaxLength(500);
        builder.Property(h => h.ActorId).IsRequired().HasMaxLength(450);
        builder.Property(h => h.ActorName).IsRequired().HasMaxLength(200);

        builder.HasOne(h => h.Ticket)
            .WithMany()
            .HasForeignKey(h => h.TicketId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(h => h.TicketId);
        builder.HasIndex(h => new { h.ActorId, h.OccurredAt });
    }
}
