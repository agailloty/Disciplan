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

namespace Disciplaner.Tests;

public sealed class ApiFactory : WebApplicationFactory<Program>
{
    private const string TestKey = "synthetic-test-only-key-never-use-in-production-123456";
    public string Root { get; } = Path.Combine(Path.GetTempPath(), "Disciplaner.Tests", Guid.NewGuid().ToString("N"));

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        Directory.CreateDirectory(Root);
        builder.UseEnvironment("Testing");
        builder.ConfigureLogging(logging => logging.ClearProviders());
        builder.UseSetting("ConnectionStrings:DefaultConnection", $"Data Source={Path.Combine(Root, "test.db")};Pooling=False");
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
    }
}
