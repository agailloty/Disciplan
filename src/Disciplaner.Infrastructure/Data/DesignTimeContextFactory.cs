using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Disciplaner.Infrastructure.Data;

// Model generation never starts the web host or runs startup migrations/seeding.
public sealed class DesignTimeContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
        => new(new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseSqlite("Data Source=disciplaner-design-only.db").Options);
}
