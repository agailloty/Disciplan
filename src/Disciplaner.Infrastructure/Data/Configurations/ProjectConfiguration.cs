using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.ToTable("Projects");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Id)
            .ValueGeneratedNever();

        builder.Property(p => p.Name)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Project.NameMaxLength);

        builder.Property(p => p.Description)
            .HasMaxLength(DomainConstraints.Project.DescriptionMaxLength);

        builder.Property(p => p.Key)
            .IsRequired()
            .HasMaxLength(DomainConstraints.Project.KeyMaxLength);

        builder.HasIndex(p => p.Key).IsUnique();

        builder.Property(p => p.OwnerId)
            .IsRequired();

        builder.Property(p => p.CreatedAt)
            .IsRequired();

        builder.Property(p => p.UpdatedAt);

        // Map the private backing field for ticket number sequencing
        builder.Property<int>("_nextTicketNumber")
            .HasColumnName("NextTicketNumber")
            .HasDefaultValue(1)
            .IsRequired()
            .UsePropertyAccessMode(PropertyAccessMode.Field);

        // Project → Members : cascade delete
        builder.HasMany(p => p.Members)
            .WithOne()
            .HasForeignKey(m => m.ProjectId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Navigation(p => p.Members)
            .UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}
