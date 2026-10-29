using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Disciplaner.Infrastructure.Data;

// Model generation never starts the web host or runs startup migrations/seeding.
public sealed class DesignTimeContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var builder = new DbContextOptionsBuilder<ApplicationDbContext>();
        var usePostgres = args.Any(a => a.Equals("--postgres", StringComparison.OrdinalIgnoreCase))
            || DatabaseConfigurationExtensions.IsPostgresProviderName(Environment.GetEnvironmentVariable("Database__Provider"));

        if (usePostgres)
        {
            builder.UseNpgsql("Host=localhost;Database=disciplaner_design;Username=postgres;Password=postgres");
        }
        else
        {
            builder.UseSqlite("Data Source=disciplaner-design-only.db");
        }

        return new ApplicationDbContext(builder.Options);
    }
}
