using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class AttachmentConfiguration : IEntityTypeConfiguration<Attachment>
{
    public void Configure(EntityTypeBuilder<Attachment> builder)
    {
        builder.ToTable("Attachments");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.Id)
            .ValueGeneratedNever();

        builder.Property(a => a.FileName)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Attachment.FileNameMaxLength);

        builder.Property(a => a.StoragePath)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Attachment.StoragePathMaxLength);

        builder.Property(a => a.ContentType)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Attachment.ContentTypeMaxLength);

        builder.Property(a => a.SizeBytes)
            .IsRequired();

        builder.Property(a => a.UploadedById)
            .IsRequired()
            .HasMaxLength(450); // ASP.NET Identity key max length

        builder.Property(a => a.UploadedAt)
            .IsRequired();

        builder.Property(a => a.TicketId)
            .IsRequired(false);

        builder.Property(a => a.CommentId)
            .IsRequired(false);

        builder.Property(a => a.BoardId)
            .IsRequired(false);

        builder.HasOne<Ticket>()
            .WithMany()
            .HasForeignKey(a => a.TicketId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne<Comment>()
            .WithMany()
            .HasForeignKey(a => a.CommentId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne<Board>()
            .WithMany()
            .HasForeignKey(a => a.BoardId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(a => a.TicketId);
        builder.HasIndex(a => a.CommentId);
        builder.HasIndex(a => a.BoardId);
        builder.HasIndex(a => a.UploadedById);
    }
}
