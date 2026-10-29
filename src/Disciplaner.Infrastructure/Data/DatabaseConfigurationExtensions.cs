using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;

namespace Disciplaner.Infrastructure.Data;

public enum DatabaseProvider
{
    Sqlite,
    Postgres
}

public sealed record ResolvedDatabaseConfig(
    DatabaseProvider Provider,
    string ConnectionString);

public static class DatabaseConfigurationExtensions
{
    public const string DefaultSqliteConnectionString = "Data Source=disciplaner.db";

    /// <summary>
    /// Resolves the database provider and connection string from <see cref="IConfiguration"/>.
    /// Priority order:
    /// 1. Explicit <c>Database:Provider</c> ("Postgres" / "PostgreSQL" or "Sqlite")
    /// 2. Explicit <c>ConnectionStrings:Postgres</c> or <c>ConnectionStrings:PostgreSql</c>
    /// 3. Cloud environment variable <c>DATABASE_URL</c>
    /// 4. <c>ConnectionStrings:DefaultConnection</c> (auto-detects PostgreSQL vs SQLite; ignores default SQLite placeholder if a Postgres source is present)
    /// 5. Fallback to SQLite (<c>Database:SqliteFallbackPath</c> or <c>Data Source=disciplaner.db</c>)
    /// </summary>
    public static ResolvedDatabaseConfig ResolveDatabaseConfig(IConfiguration configuration)
    {
        var explicitProvider = configuration["Database:Provider"]?.Trim();
        var pgConn = FirstNonEmpty(
            configuration.GetConnectionString("Postgres"),
            configuration.GetConnectionString("PostgreSql"),
            configuration["DATABASE_URL"]);
        var defaultConn = configuration.GetConnectionString("DefaultConnection")?.Trim();
        var sqliteFallbackPath = configuration["Database:SqliteFallbackPath"]?.Trim();
        var fallbackSqlite = !string.IsNullOrWhiteSpace(sqliteFallbackPath)
            ? (sqliteFallbackPath.Contains("Data Source=", StringComparison.OrdinalIgnoreCase)
                ? sqliteFallbackPath
                : $"Data Source={sqliteFallbackPath}")
            : DefaultSqliteConnectionString;

        // 1. Explicit provider override
        if (!string.IsNullOrWhiteSpace(explicitProvider))
        {
            if (IsPostgresProviderName(explicitProvider))
            {
                var raw = FirstNonEmpty(pgConn, defaultConn)
                    ?? throw new InvalidOperationException(
                        "Database:Provider is set to Postgres, but no PostgreSQL connection string was provided " +
                        "(set ConnectionStrings__Postgres, ConnectionStrings__DefaultConnection, or DATABASE_URL).");
                return new ResolvedDatabaseConfig(DatabaseProvider.Postgres, NormalizePostgresConnectionString(raw));
            }

            if (IsSqliteProviderName(explicitProvider))
            {
                var raw = FirstNonEmpty(defaultConn, fallbackSqlite)!;
                return new ResolvedDatabaseConfig(DatabaseProvider.Sqlite, raw);
            }

            throw new InvalidOperationException(
                $"Unsupported Database:Provider '{explicitProvider}'. Supported values are 'Postgres' and 'Sqlite'.");
        }

        // 2. Priority to explicit Postgres connection string or DATABASE_URL
        if (!string.IsNullOrWhiteSpace(pgConn))
        {
            if (LooksLikeSqliteConnectionString(pgConn))
            {
                return new ResolvedDatabaseConfig(DatabaseProvider.Sqlite, pgConn);
            }
            return new ResolvedDatabaseConfig(DatabaseProvider.Postgres, NormalizePostgresConnectionString(pgConn));
        }

        // 3. Check DefaultConnection
        if (!string.IsNullOrWhiteSpace(defaultConn))
        {
            if (LooksLikePostgresConnectionString(defaultConn))
            {
                return new ResolvedDatabaseConfig(DatabaseProvider.Postgres, NormalizePostgresConnectionString(defaultConn));
            }

            return new ResolvedDatabaseConfig(DatabaseProvider.Sqlite, defaultConn);
        }

        // 4. Fallback to SQLite when nothing is specified
        return new ResolvedDatabaseConfig(DatabaseProvider.Sqlite, fallbackSqlite);
    }

    public static IServiceCollection AddDisciplanerDatabase(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var resolved = ResolveDatabaseConfig(configuration);

        services.AddSingleton(resolved);
        services.AddDbContext<ApplicationDbContext>(options =>
        {
            ConfigureDbContext(options, resolved);
        });

        return services;
    }

    public static void ConfigureDbContext(
        DbContextOptionsBuilder options,
        ResolvedDatabaseConfig resolved)
    {
        // Shared cross-provider migrations use runtime provider detection in MigrationBuilder,
        // while the design-time snapshot uses SQLite store type names. Suppress the snapshot
        // store-type diff check when running under PostgreSQL.
        options.ConfigureWarnings(w => w.Ignore(RelationalEventId.PendingModelChangesWarning));

        if (resolved.Provider == DatabaseProvider.Postgres)
        {
            options.UseNpgsql(resolved.ConnectionString);
        }
        else
        {
            options.UseSqlite(resolved.ConnectionString);
        }
    }

    public static bool IsPostgresProviderName(string? name)
        => string.Equals(name, "Postgres", StringComparison.OrdinalIgnoreCase)
           || string.Equals(name, "PostgreSQL", StringComparison.OrdinalIgnoreCase)
           || string.Equals(name, "Npgsql", StringComparison.OrdinalIgnoreCase);

    public static bool IsSqliteProviderName(string? name)
        => string.Equals(name, "Sqlite", StringComparison.OrdinalIgnoreCase)
           || string.Equals(name, "SQLite3", StringComparison.OrdinalIgnoreCase);

    public static bool LooksLikePostgresConnectionString(string connectionString)
    {
        var trimmed = connectionString.Trim();
        if (trimmed.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            || trimmed.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
            return true;

        if (LooksLikeSqliteConnectionString(trimmed))
            return false;

        return trimmed.Contains("Host=", StringComparison.OrdinalIgnoreCase)
            || trimmed.Contains("Server=", StringComparison.OrdinalIgnoreCase)
            || trimmed.Contains("Username=", StringComparison.OrdinalIgnoreCase)
            || trimmed.Contains("User ID=", StringComparison.OrdinalIgnoreCase)
            || trimmed.Contains("User Id=", StringComparison.OrdinalIgnoreCase);
    }

    public static bool LooksLikeSqliteConnectionString(string connectionString)
    {
        var trimmed = connectionString.Trim();
        return trimmed.Contains("Data Source=", StringComparison.OrdinalIgnoreCase)
            || trimmed.Contains("Filename=", StringComparison.OrdinalIgnoreCase)
            || trimmed.EndsWith(".db", StringComparison.OrdinalIgnoreCase)
            || trimmed.EndsWith(".sqlite", StringComparison.OrdinalIgnoreCase)
            || trimmed.EndsWith(".sqlite3", StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Converts Cloud URI connection strings (<c>postgres://user:pass@host:port/db?sslmode=require</c>)
    /// or standard Npgsql key-value connection strings into a normalized Npgsql connection string.
    /// </summary>
    public static string NormalizePostgresConnectionString(string rawConnectionString)
    {
        var trimmed = rawConnectionString.Trim();
        if (!trimmed.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            && !trimmed.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            return trimmed;
        }

        var uri = new Uri(trimmed);
        var builder = new NpgsqlConnectionStringBuilder
        {
            Host = uri.Host,
            Port = uri.Port > 0 ? uri.Port : 5432,
            Database = Uri.UnescapeDataString(uri.AbsolutePath.TrimStart('/'))
        };

        if (!string.IsNullOrEmpty(uri.UserInfo))
        {
            var parts = uri.UserInfo.Split(':', 2);
            builder.Username = Uri.UnescapeDataString(parts[0]);
            if (parts.Length > 1)
                builder.Password = Uri.UnescapeDataString(parts[1]);
        }

        if (!string.IsNullOrEmpty(uri.Query))
        {
            var query = uri.Query.TrimStart('?');
            foreach (var pair in query.Split('&', StringSplitOptions.RemoveEmptyEntries))
            {
                var kv = pair.Split('=', 2);
                var key = Uri.UnescapeDataString(kv[0]).Trim();
                var val = kv.Length > 1 ? Uri.UnescapeDataString(kv[1]).Trim() : string.Empty;

                if (key.Equals("sslmode", StringComparison.OrdinalIgnoreCase))
                {
                    if (Enum.TryParse<SslMode>(val, ignoreCase: true, out var sslMode))
                        builder.SslMode = sslMode;
                }
                else if (key.Equals("pooling", StringComparison.OrdinalIgnoreCase) && bool.TryParse(val, out var pooling))
                {
                    builder.Pooling = pooling;
                }
                else if (key.Equals("search_path", StringComparison.OrdinalIgnoreCase) || key.Equals("options", StringComparison.OrdinalIgnoreCase))
                {
                    builder.SearchPath = val;
                }
            }
        }

        return builder.ConnectionString;
    }

    private static string? FirstNonEmpty(params string?[] values)
        => values.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v))?.Trim();
}
