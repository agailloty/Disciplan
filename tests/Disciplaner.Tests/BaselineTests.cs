using System.Net;
using System.Text.Json;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Disciplaner.Domain.Exceptions;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Disciplaner.Tests;

public class BaselineTests
{
    [Fact]
    public void Membership_revocation_removes_access_and_owner_cannot_be_demoted()
    {
        var project = new Project("Fixture", null, "FIX", BaselineFixture.User("owner"));
        project.AddMember("member", MemberRole.Member);
        Assert.True(project.CanWrite("member"));
        project.RemoveMember("member");
        Assert.False(project.HasAccess("member"));
        Assert.False(project.CanWrite("member"));
        Assert.Throws<MembershipDomainException>(() => project.ChangeMemberRole("owner", MemberRole.Guest));
        Assert.True(project.CanAdminister("owner"));
    }

    [Theory]
    [InlineData("owner", HttpStatusCode.OK)]
    [InlineData("supervisor", HttpStatusCode.OK)]
    [InlineData("member", HttpStatusCode.OK)]
    [InlineData("guest", HttpStatusCode.OK)]
    [InlineData("removed", HttpStatusCode.Forbidden)]
    [InlineData("outsider", HttpStatusCode.Forbidden)]
    [InlineData(null, HttpStatusCode.Unauthorized)]
    public async Task Ticket_detail_enforces_membership(string? user, HttpStatusCode expected)
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor(user);
        using var response = await client.GetAsync($"/api/tickets/{BaselineFixture.Id("ticket-0")}");
        Assert.Equal(expected, response.StatusCode);
    }

    [Fact]
    public async Task Project_list_excludes_isolated_projects()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        using var response = await client.GetAsync("/api/projects");
        response.EnsureSuccessStatusCode();
        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(BaselineFixture.SharedProjectId, Assert.Single(payload.RootElement.EnumerateArray()).GetProperty("id").GetGuid());
    }

    [Fact]
    [Trait("Category", "Volume")]
    public async Task Volume_fixture_contains_exactly_10000_tickets_20_projects_50_users()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync(volume: true);
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Equal(10000, await db.Tickets.CountAsync());
        Assert.Equal(20, await db.Projects.CountAsync());
        Assert.Equal(50, await db.Users.CountAsync());
        Assert.Equal(2, await db.Comments.CountAsync());
        Assert.Equal(3, await db.Attachments.CountAsync());
        Assert.Equal(3, Directory.GetFiles(Path.Combine(factory.Root, "uploads")).Length);
        Assert.All(await db.Tickets.ToListAsync(), ticket => Assert.Equal(BaselineFixture.Epoch, ticket.CreatedAt));
    }
}
