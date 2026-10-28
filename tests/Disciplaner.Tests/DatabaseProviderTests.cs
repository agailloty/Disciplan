using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Disciplaner.Tests;

public class DatabaseProviderTests
{
    private static IConfiguration BuildConfig(Dictionary<string, string?> values)
        => new ConfigurationBuilder().AddInMemoryCollection(values).Build();

    [Fact]
    public void Fallback_to_sqlite_when_nothing_is_specified()
    {
        var config = BuildConfig([]);
        var resolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(config);

        Assert.Equal(DatabaseProvider.Sqlite, resolved.Provider);
        Assert.Equal(DatabaseConfigurationExtensions.DefaultSqliteConnectionString, resolved.ConnectionString);
    }

    [Fact]
    public void Fallback_uses_custom_sqlite_fallback_path_when_configured()
    {
        var config = BuildConfig(new()
        {
            ["Database:SqliteFallbackPath"] = "/data/disciplaner.db"
        });
        var resolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(config);

        Assert.Equal(DatabaseProvider.Sqlite, resolved.Provider);
        Assert.Equal("Data Source=/data/disciplaner.db", resolved.ConnectionString);
    }

    [Fact]
    public void Postgres_connection_string_takes_priority_over_sqlite_default()
    {
        var config = BuildConfig(new()
        {
            ["ConnectionStrings:Postgres"] = "Host=pg.internal;Port=5432;Database=disciplan;Username=app;Password=secret",
            ["ConnectionStrings:DefaultConnection"] = "Data Source=disciplaner.db"
        });
        var resolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(config);

        Assert.Equal(DatabaseProvider.Postgres, resolved.Provider);
        Assert.Contains("Host=pg.internal", resolved.ConnectionString);
    }

    [Fact]
    public void Cloud_database_url_uri_is_prioritized_and_converted_to_npgsql_format()
    {
        var config = BuildConfig(new()
        {
            ["DATABASE_URL"] = "postgresql://cloud_user:p%40ssw0rd@ep-cool-cloud-123.eu-central-1.aws.neon.tech:5432/disciplan_prod?sslmode=require",
            ["Database:SqliteFallbackPath"] = "/data/disciplaner.db"
        });
        var resolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(config);

        Assert.Equal(DatabaseProvider.Postgres, resolved.Provider);
        Assert.Contains("Host=ep-cool-cloud-123.eu-central-1.aws.neon.tech", resolved.ConnectionString);
        Assert.Contains("Port=5432", resolved.ConnectionString);
        Assert.Contains("Database=disciplan_prod", resolved.ConnectionString);
        Assert.Contains("Username=cloud_user", resolved.ConnectionString);
        Assert.Contains("Password=p@ssw0rd", resolved.ConnectionString);
        Assert.Contains("SSL Mode=Require", resolved.ConnectionString);
    }

    [Fact]
    public void Default_connection_auto_detects_postgres_ado_net_and_uri_formats()
    {
        var adoConfig = BuildConfig(new()
        {
            ["ConnectionStrings:DefaultConnection"] = "Host=localhost;Database=disciplan;Username=postgres;Password=postgres"
        });
        var adoResolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(adoConfig);
        Assert.Equal(DatabaseProvider.Postgres, adoResolved.Provider);

        var uriConfig = BuildConfig(new()
        {
            ["ConnectionStrings:DefaultConnection"] = "postgres://postgres:postgres@localhost:5432/disciplan"
        });
        var uriResolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(uriConfig);
        Assert.Equal(DatabaseProvider.Postgres, uriResolved.Provider);
        Assert.Contains("Host=localhost", uriResolved.ConnectionString);
    }

    [Fact]
    public void Explicit_provider_throws_when_postgres_selected_without_connection_string()
    {
        var config = BuildConfig(new()
        {
            ["Database:Provider"] = "Postgres"
        });

        Assert.Throws<InvalidOperationException>(() =>
            DatabaseConfigurationExtensions.ResolveDatabaseConfig(config));
    }

    [Fact]
    public void Explicit_sqlite_provider_forces_sqlite_even_if_empty_connection()
    {
        var config = BuildConfig(new()
        {
            ["Database:Provider"] = "Sqlite"
        });
        var resolved = DatabaseConfigurationExtensions.ResolveDatabaseConfig(config);

        Assert.Equal(DatabaseProvider.Sqlite, resolved.Provider);
        Assert.Equal(DatabaseConfigurationExtensions.DefaultSqliteConnectionString, resolved.ConnectionString);
    }
}

