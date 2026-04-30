using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class CommentConfiguration : IEntityTypeConfiguration<Comment>
{
    public void Configure(EntityTypeBuilder<Comment> builder)
    {
        builder.ToTable("Comments");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Id)
            .ValueGeneratedNever();

        builder.Property(c => c.Content)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Comment.ContentMaxLength);

        builder.Property(c => c.AuthorId)
            .IsRequired()
            .HasMaxLength(450); // ASP.NET Identity key max length

        builder.Property(c => c.CreatedAt)
            .IsRequired();

        builder.Property(c => c.UpdatedAt);

        builder.Property(c => c.CardId)
            .IsRequired(false);

        builder.HasOne(c => c.Card)
            .WithMany()
            .HasForeignKey(c => c.CardId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(c => c.TicketId)
            .IsRequired(false);

        builder.HasOne(c => c.Ticket)
            .WithMany()
            .HasForeignKey(c => c.TicketId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(c => new { c.CardId, c.CreatedAt });
        builder.HasIndex(c => new { c.TicketId, c.CreatedAt });
    }
}
