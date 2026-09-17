using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Disciplaner.Infrastructure.Data;
using Disciplaner.Infrastructure.Storage;
using Disciplaner.Application;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Xunit;

namespace Disciplaner.Tests;

public class IntegrityTests
{
    private static readonly Guid TicketId = BaselineFixture.Id("ticket-0");
    private static readonly Guid SprintId = BaselineFixture.Id("sprint-0");

    [Fact]
    public async Task Saved_view_and_label_items_are_scoped_before_results()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        Guid viewId, labelId;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var view = new SavedView("All", null, "member");
            var label = new Label("Global taxonomy", "#123456");
            foreach (var ticket in await db.Tickets.ToListAsync()) label.AddTicket(ticket);
            db.SavedViews.Add(view); db.Labels.Add(label);
            await db.SaveChangesAsync(); viewId = view.Id; labelId = label.Id;
        }
        using var client = factory.ClientFor("member");
        var tickets = await client.GetFromJsonAsync<JsonElement>($"/api/saved-views/{viewId}/tickets");
        Assert.Equal(2, tickets.GetArrayLength());
        Assert.All(tickets.EnumerateArray(), t => Assert.Equal(BaselineFixture.SharedProjectId, t.GetProperty("projectId").GetGuid()));
        var items = await client.GetFromJsonAsync<JsonElement>($"/api/labels/{labelId}/items");
        Assert.Equal(2, items.GetProperty("tickets").GetArrayLength());
        using var guest = factory.ClientFor("guest");
        Assert.Equal(HttpStatusCode.Forbidden, (await guest.PostAsync($"/api/labels/{labelId}/tickets/{TicketId}", null)).StatusCode);
    }

    [Fact]
    public async Task Removed_member_loses_personal_views_activity_files_and_comments()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        var commentResponse = await client.PostAsJsonAsync($"/api/tickets/{TicketId}/comments", new { content = "Previously authorized" });
        commentResponse.EnsureSuccessStatusCode();
        var comment = await commentResponse.Content.ReadFromJsonAsync<JsonElement>();
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var project = await db.Projects.Include(p => p.Members).SingleAsync(p => p.Id == BaselineFixture.SharedProjectId);
            (await db.Tickets.FindAsync(TicketId))!.Assign("member");
            project.RemoveMember("member");
            await db.SaveChangesAsync();
        }
        Assert.Empty((await client.GetFromJsonAsync<JsonElement>("/api/tickets/mine")).EnumerateArray());
        var remainingActivity = (await client.GetFromJsonAsync<JsonElement>("/api/activity/recent")).EnumerateArray();
        Assert.Equal("Synthetic card comment", Assert.Single(remainingActivity).GetProperty("summary").GetString());
        Assert.Empty((await client.GetFromJsonAsync<JsonElement>("/api/activity/grouped")).EnumerateArray());
        Assert.Equal(HttpStatusCode.Forbidden, (await client.PutAsJsonAsync($"/api/comments/{comment.GetProperty("id").GetGuid()}", new { content = "Forbidden" })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync($"/api/tickets/{TicketId}/attachments")).StatusCode);
    }

    [Theory]
    [InlineData("guest")]
    [InlineData("member")]
    [InlineData("outsider")]
    public async Task Sprint_management_requires_supervisor(string user)
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor(user);
        Assert.Equal(HttpStatusCode.Forbidden, (await client.PutAsJsonAsync($"/api/sprints/{SprintId}", new { name = "Forbidden", goal = "x" })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await client.DeleteAsync($"/api/sprints/{SprintId}")).StatusCode);
    }

    [Fact]
    public async Task Guest_cannot_comment_or_upload()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("guest");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.PostAsJsonAsync($"/api/tickets/{TicketId}/comments", new { content = "No" })).StatusCode);
        using var body = new MultipartFormDataContent();
        var file = new ByteArrayContent([65, 66]); file.Headers.ContentType = new("text/plain");
        body.Add(file, "file", "fixture.txt");
        Assert.Equal(HttpStatusCode.Forbidden, (await client.PostAsync($"/api/tickets/{TicketId}/attachments", body)).StatusCode);
    }

    [Fact]
    public async Task Invalid_relations_do_not_write_or_consume_number()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        foreach (var data in new object[] {
            new { title = "Bad", type = 2, sprintId = BaselineFixture.Id("sprint-1") },
            new { title = "Bad", type = 2, parentTicketId = BaselineFixture.Id("ticket-1") },
            new { title = "Bad", type = 2, assigneeId = "outsider" },
            new { title = "Bad", type = 2, storyPoints = -1 }
        })
            Assert.Equal(HttpStatusCode.BadRequest, (await client.PostAsJsonAsync($"/api/projects/{BaselineFixture.SharedProjectId}/tickets", data)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/tickets/{TicketId}/sprint", new { sprintId = BaselineFixture.Id("sprint-1") })).StatusCode);
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Equal(4, await db.Tickets.CountAsync());
        Assert.Empty(await db.TicketHistories.ToListAsync());
        Assert.Equal(3, await db.Projects.Where(p => p.Id == BaselineFixture.SharedProjectId).Select(p => EF.Property<int>(p, "_nextTicketNumber")).SingleAsync());
    }

    [Fact]
    public async Task Nullable_fields_clear_and_history_matches()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        (await client.PutAsJsonAsync($"/api/tickets/{TicketId}", new { title = "Nullable", type = 2, priority = 1, storyPoints = 5, dueDate = "2027-01-01T00:00:00Z", assigneeId = "member" })).EnsureSuccessStatusCode();
        (await client.PutAsJsonAsync($"/api/tickets/{TicketId}", new { title = "Nullable", type = 2, priority = 1, storyPoints = (int?)null, dueDate = (DateTime?)null, assigneeId = "member" })).EnsureSuccessStatusCode();
        var ticket = await client.GetFromJsonAsync<JsonElement>($"/api/tickets/{TicketId}");
        Assert.Equal(JsonValueKind.Null, ticket.GetProperty("storyPoints").ValueKind);
        Assert.Equal(JsonValueKind.Null, ticket.GetProperty("dueDate").ValueKind);
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Equal(2, await db.TicketHistories.CountAsync(h => h.NewValue == null && (h.Kind == "story_points_changed" || h.Kind == "due_date_changed")));
    }

    [Fact]
    public async Task Concurrent_creation_keeps_unique_numbers_and_complete_history()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        var responses = await Task.WhenAll(Enumerable.Range(0, 6).Select(i => client.PostAsJsonAsync(
            $"/api/projects/{BaselineFixture.SharedProjectId}/tickets", new { title = "Concurrent " + i, type = 2 })));
        foreach (var response in responses) response.EnsureSuccessStatusCode();
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var numbers = await db.Tickets.Where(t => t.ProjectId == BaselineFixture.SharedProjectId).Select(t => t.TicketNumber).ToListAsync();
        Assert.Equal(8, numbers.Count);
        Assert.Equal(8, numbers.Distinct().Count());
        Assert.Equal(6, await db.TicketHistories.CountAsync(h => h.Kind == "created"));
    }

    [Fact]
    public async Task Deactivated_account_loses_existing_jwt()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        using var client = factory.ClientFor("member");
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            (await db.Users.FindAsync("member"))!.IsActive = false;
            await db.SaveChangesAsync();
        }
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.GetAsync("/api/projects")).StatusCode);
    }

    [Fact]
    public async Task Sprint_dates_lifecycle_and_concurrent_start_are_enforced()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        Guid second;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var project = await db.Projects.FindAsync(BaselineFixture.SharedProjectId);
            var sprint = project!.AddSprint("Second", null); db.Sprints.Add(sprint);
            await db.SaveChangesAsync(); second = sprint.Id;
        }
        using var client = factory.ClientFor("supervisor");
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/sprints/{SprintId}/start", new { startDate = "2026-10-02", endDate = "2026-10-01" })).StatusCode);
        var starts = await Task.WhenAll(new[] { SprintId, second }.Select(id => client.PutAsJsonAsync($"/api/sprints/{id}/start",
            new { startDate = "2026-10-01T00:00:00Z", endDate = "2026-10-15T00:00:00Z" })));
        Assert.Single(starts, r => r.StatusCode == HttpStatusCode.OK);
        Assert.Single(starts, r => r.StatusCode == HttpStatusCode.BadRequest);
        using var verify = factory.Services.CreateScope();
        var context = verify.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        Assert.Equal(1, await context.Sprints.CountAsync(s => s.Status == SprintStatus.Active));
    }

    [Fact]
    public async Task Calendar_rechecks_membership_and_active_account()
    {
        using var factory = new ApiFactory();
        await factory.SeedAsync();
        string token;
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var ticket = (await db.Tickets.FindAsync(TicketId))!;
            ticket.Assign("member"); ticket.SetDueDate(new DateTime(2027, 1, 1));
            var subscription = new CalendarToken("member");
            db.CalendarTokens.Add(subscription);
            await db.SaveChangesAsync(); token = subscription.Token;
        }
        using var client = factory.ClientFor(null);
        Assert.Contains("Fixture ticket", await client.GetStringAsync("/ical/" + token));
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var project = await db.Projects.Include(p => p.Members).SingleAsync(p => p.Id == BaselineFixture.SharedProjectId);
            project.RemoveMember("member"); await db.SaveChangesAsync();
        }
        Assert.DoesNotContain("Fixture ticket", await client.GetStringAsync("/ical/" + token));
        using (var scope = factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            (await db.Users.FindAsync("member"))!.IsActive = false; await db.SaveChangesAsync();
        }
        Assert.Equal(HttpStatusCode.NotFound, (await client.GetAsync("/ical/" + token)).StatusCode);
    }

    [Theory]
    [InlineData("../outside.txt")]
    [InlineData("profiles/../ticket.txt")]
    [InlineData("profiles/..\\ticket.txt")]
    [InlineData("/absolute.txt")]
    public void Storage_rejects_escaping_paths(string path)
    {
        var storage = new LocalFileStorageService(Options.Create(new FileStorageOptions { BasePath = Path.Combine(Path.GetTempPath(), "fixture-storage") }));
        Assert.Throws<ArgumentException>(() => storage.GetAbsolutePath(path));
    }
}
