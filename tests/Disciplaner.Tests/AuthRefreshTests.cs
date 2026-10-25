using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using Disciplaner.Web.Server.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.IdentityModel.Tokens;
using Xunit;

namespace Disciplaner.Tests;

public class AuthRefreshTests
{
    private static string TokenFor(ApiFactory factory, string user, DateTime expiresAt)
    {
        var settings = factory.Services.GetRequiredService<IOptions<JwtSettings>>().Value;
        var token = new JwtSecurityToken(settings.Issuer, settings.Audience,
            [new Claim(ClaimTypes.NameIdentifier, user)],
            expires: expiresAt,
            signingCredentials: new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(settings.SecretKey)),
                SecurityAlgorithms.HmacSha256));
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private static HttpClient ClientWithToken(ApiFactory factory, string? token)
    {
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            BaseAddress = new Uri("https://localhost"),
            AllowAutoRedirect = false
        });
        if (token is not null)
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return client;
    }

    [Fact]
    public async Task Refresh_exchanges_a_recently_expired_token_for_a_valid_one()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        // Expired one hour ago — within the 30-day refresh window.
        using var client = ClientWithToken(factory, TokenFor(factory, "member", DateTime.UtcNow.AddHours(-1)));
        using var response = await client.PostAsync("/api/auth/refresh", content: null);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var root = payload.RootElement;
        Assert.Equal("member@example.invalid", root.GetProperty("email").GetString());
        Assert.True(root.GetProperty("expiresAt").GetDateTime() > DateTime.UtcNow);

        // The freshly issued token must authenticate against a protected route.
        using var refreshed = ClientWithToken(factory, root.GetProperty("token").GetString());
        using var projects = await refreshed.GetAsync("/api/projects");
        Assert.Equal(HttpStatusCode.OK, projects.StatusCode);
    }

    [Fact]
    public async Task Refresh_accepts_a_still_valid_token()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = ClientWithToken(factory, TokenFor(factory, "owner", DateTime.UtcNow.AddMinutes(15)));
        using var response = await client.PostAsync("/api/auth/refresh", content: null);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Refresh_rejects_a_token_expired_beyond_the_window()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = ClientWithToken(factory, TokenFor(factory, "member", DateTime.UtcNow.AddDays(-31)));
        using var response = await client.PostAsync("/api/auth/refresh", content: null);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Refresh_rejects_missing_token_garbage_and_unknown_user()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();

        using (var client = ClientWithToken(factory, null))
        {
            using var response = await client.PostAsync("/api/auth/refresh", content: null);
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }

        using (var client = ClientWithToken(factory, "not-a-jwt"))
        {
            using var response = await client.PostAsync("/api/auth/refresh", content: null);
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }

        using (var client = ClientWithToken(factory, TokenFor(factory, "does-not-exist", DateTime.UtcNow.AddMinutes(15))))
        {
            using var response = await client.PostAsync("/api/auth/refresh", content: null);
            Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        }
    }

    [Fact]
    public async Task Refresh_rejects_a_token_signed_by_another_key()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        var attackerToken = new JwtSecurityTokenHandler().WriteToken(new JwtSecurityToken(
            "fixture", "fixture", [new Claim(ClaimTypes.NameIdentifier, "member")],
            expires: DateTime.UtcNow.AddMinutes(15),
            signingCredentials: new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes("another-key-with-32-characters-minimum!!")),
                SecurityAlgorithms.HmacSha256)));
        using var client = ClientWithToken(factory, attackerToken);
        using var response = await client.PostAsync("/api/auth/refresh", content: null);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
