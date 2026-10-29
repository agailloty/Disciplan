using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using Disciplaner.Infrastructure.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Npgsql;

namespace Disciplaner.Tests;

public sealed class ApiFactory : WebApplicationFactory<Program>
{
    private const string TestKey = "synthetic-test-only-key-never-use-in-production-123456";
    private readonly string? _postgresBaseConnection;
    private readonly string? _postgresTestDatabaseName;

    public string Root { get; } = Path.Combine(Path.GetTempPath(), "Disciplaner.Tests", Guid.NewGuid().ToString("N"));

    public ApiFactory(string? postgresConnectionString = null)
    {
        _postgresBaseConnection = postgresConnectionString
            ?? Environment.GetEnvironmentVariable("TEST_POSTGRES_CONNECTION");

        if (!string.IsNullOrWhiteSpace(_postgresBaseConnection))
        {
            _postgresTestDatabaseName = $"disciplan_test_{Guid.NewGuid():N}";
            CreatePostgresDatabase(_postgresBaseConnection, _postgresTestDatabaseName);
        }
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        Directory.CreateDirectory(Root);
        builder.UseEnvironment("Testing");
        builder.ConfigureLogging(logging => logging.ClearProviders());

        if (!string.IsNullOrWhiteSpace(_postgresBaseConnection) && !string.IsNullOrWhiteSpace(_postgresTestDatabaseName))
        {
            var normalized = DatabaseConfigurationExtensions.NormalizePostgresConnectionString(_postgresBaseConnection);
            var pgBuilder = new NpgsqlConnectionStringBuilder(normalized)
            {
                Database = _postgresTestDatabaseName,
                Pooling = false
            };
            builder.UseSetting("ConnectionStrings:Postgres", pgBuilder.ConnectionString);
            builder.UseSetting("ConnectionStrings:DefaultConnection", "");
        }
        else
        {
            builder.UseSetting("ConnectionStrings:Postgres", "");
            builder.UseSetting("ConnectionStrings:DefaultConnection", $"Data Source={Path.Combine(Root, "test.db")};Pooling=False");
        }

        builder.UseSetting("Jwt:SecretKey", TestKey);
        builder.UseSetting("Jwt:Issuer", "fixture");
        builder.UseSetting("Jwt:Audience", "fixture");
        builder.UseSetting("AdminSeed:Email", "");
        builder.UseSetting("AdminSeed:Password", "");
        builder.UseSetting("FileStorage:BasePath", Path.Combine(Root, "uploads"));
    }

    public async Task SeedAsync(bool volume = false)
    {
        using var scope = Services.CreateScope();
        await BaselineFixture.SeedAsync(scope.ServiceProvider.GetRequiredService<ApplicationDbContext>(), Path.Combine(Root, "uploads"), volume);
    }

    public HttpClient ClientFor(string? user)
    {
        var client = CreateClient(new WebApplicationFactoryClientOptions { BaseAddress = new Uri("https://localhost"), AllowAutoRedirect = false });
        if (user is not null)
        {
            var token = new JwtSecurityToken("fixture", "fixture", [new Claim(ClaimTypes.NameIdentifier, user)],
                expires: DateTime.UtcNow.AddMinutes(15), signingCredentials: new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(TestKey)), SecurityAlgorithms.HmacSha256));
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", new JwtSecurityTokenHandler().WriteToken(token));
        }
        return client;
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        // Root is a unique directory created by this fixture, never a configured application path.
        if (disposing && Directory.Exists(Root)) Directory.Delete(Root, recursive: true);

        if (disposing && !string.IsNullOrWhiteSpace(_postgresBaseConnection) && !string.IsNullOrWhiteSpace(_postgresTestDatabaseName))
        {
            DropPostgresDatabase(_postgresBaseConnection, _postgresTestDatabaseName);
        }
    }

    private static void CreatePostgresDatabase(string baseConnectionString, string dbName)
    {
        var normalized = DatabaseConfigurationExtensions.NormalizePostgresConnectionString(baseConnectionString);
        var adminBuilder = new NpgsqlConnectionStringBuilder(normalized) { Database = "postgres", Pooling = false };
        using var conn = new NpgsqlConnection(adminBuilder.ConnectionString);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = $"CREATE DATABASE \"{dbName}\";";
        cmd.ExecuteNonQuery();
    }

    private static void DropPostgresDatabase(string baseConnectionString, string dbName)
    {
        try
        {
            var normalized = DatabaseConfigurationExtensions.NormalizePostgresConnectionString(baseConnectionString);
            var adminBuilder = new NpgsqlConnectionStringBuilder(normalized) { Database = "postgres", Pooling = false };
            using var conn = new NpgsqlConnection(adminBuilder.ConnectionString);
            conn.Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = $"""
                SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '{dbName}' AND pid <> pg_backend_pid();
                DROP DATABASE IF EXISTS "{dbName}";
                """;
            cmd.ExecuteNonQuery();
        }
        catch
        {
            // Best-effort cleanup of isolated test database
        }
    }
}
