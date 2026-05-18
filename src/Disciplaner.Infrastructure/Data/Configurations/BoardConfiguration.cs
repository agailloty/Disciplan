using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class BoardConfiguration : IEntityTypeConfiguration<Board>
{
    public void Configure(EntityTypeBuilder<Board> builder)
    {
        builder.ToTable("Boards");

        builder.HasKey(b => b.Id);

        builder.Property(b => b.Id)
            .ValueGeneratedNever();

        builder.Property(b => b.Name)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Board.NameMaxLength);

        builder.Property(b => b.Description)
            .HasMaxLength(DomainConstraints.Board.DescriptionMaxLength);

        builder.Property(b => b.OwnerId)
            .IsRequired();

        builder.Property(b => b.CreatedAt)
            .IsRequired();

        builder.Property(b => b.UpdatedAt);

        // OwnerId is a plain FK string to AspNetUsers.Id.
        // The Owner navigation is ignored — Domain.User is not tracked by EF.
        builder.Ignore(b => b.Owner);

        builder.HasIndex(b => b.OwnerId);

        // Board → Columns : cascade delete
        builder.HasMany(b => b.Columns)
            .WithOne(c => c.Board)
            .HasForeignKey(c => c.BoardId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Navigation(b => b.Columns)
            .UsePropertyAccessMode(PropertyAccessMode.Field);

        // Board → Members : cascade delete
        builder.HasMany(b => b.Members)
            .WithOne()
            .HasForeignKey(m => m.BoardId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Navigation(b => b.Members)
            .UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}
