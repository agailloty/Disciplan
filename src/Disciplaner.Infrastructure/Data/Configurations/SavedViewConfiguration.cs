using Disciplaner.Domain.Common;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System.Text.Json;

namespace Disciplaner.Infrastructure.Data.Configurations;

internal sealed class SavedViewConfiguration : IEntityTypeConfiguration<SavedView>
{
    public void Configure(EntityTypeBuilder<SavedView> builder)
    {
        builder.ToTable("SavedViews");

        builder.HasKey(v => v.Id);

        builder.Property(v => v.Id)
            .ValueGeneratedNever();

        builder.Property(v => v.Name)
            .IsRequired()
            .HasMaxLength(DomainConstraints.SavedView.NameMaxLength);

        builder.Property(v => v.Description)
            .HasMaxLength(DomainConstraints.SavedView.DescriptionMaxLength);

        // Serialize List<StatusCategory> as a JSON string in a single column
        builder.Property(v => v.StatusCategories)
            .HasColumnName("StatusCategories")
            .HasConversion(
                list => JsonSerializer.Serialize(list, (JsonSerializerOptions?)null),
                json => string.IsNullOrEmpty(json)
                    ? new List<StatusCategory>()
                    : JsonSerializer.Deserialize<List<StatusCategory>>(json, (JsonSerializerOptions?)null)!,
                new ValueComparer<List<StatusCategory>>(
                    (a, b) => a != null && b != null && a.SequenceEqual(b),
                    c => c.Aggregate(0, (acc, v) => HashCode.Combine(acc, v.GetHashCode())),
                    c => c.ToList()))
            .IsRequired()
            .HasDefaultValueSql("'[]'");
    }
}
