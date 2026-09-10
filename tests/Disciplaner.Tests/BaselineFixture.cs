using System.Security.Cryptography;
using System.Text;
using Disciplaner.Domain.Entities;
using Disciplaner.Domain.Enums;
using Disciplaner.Infrastructure.Data;
using Disciplaner.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Tests;

public static class BaselineFixture
{
    public static readonly DateTime Epoch = new(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    public static readonly Guid SharedProjectId = Id("project-shared");
    public static Guid Id(string name) => new(SHA256.HashData(Encoding.UTF8.GetBytes(name)).AsSpan(0, 16));
    public static User User(string name) => new(name, name, name + "@example.invalid", name);

    // Reflection is confined to fixture construction: production entities intentionally own IDs/dates.
    private static T Stable<T>(T entity, string key) where T : class
    {
        foreach (var property in typeof(T).GetProperties())
        {
            if (property.Name == "Id" && property.PropertyType == typeof(Guid)) property.SetValue(entity, Id(key));
            if (property.CanWrite && property.PropertyType == typeof(DateTime)) property.SetValue(entity, Epoch);
            if (property.CanWrite && property.PropertyType == typeof(DateTime?)) property.SetValue(entity, null);
        }
        return entity;
    }

    public static async Task SeedAsync(ApplicationDbContext db, string uploads, bool volume = false)
    {
        if (await db.Projects.AnyAsync()) throw new InvalidOperationException("Fixture requires an empty database.");
        var names = new[] { "owner", "guest", "member", "supervisor", "removed", "outsider" }
            .Concat(volume ? Enumerable.Range(6, 44).Select(i => $"user-{i:00}") : []);
        foreach (var name in names)
            db.Users.Add(new ApplicationUser { Id = name, UserName = name, NormalizedUserName = name.ToUpperInvariant(),
                Email = name + "@example.invalid", NormalizedEmail = (name + "@example.invalid").ToUpperInvariant(),
                DisplayName = name, CreatedAt = Epoch, SecurityStamp = Id(name).ToString() });
        var projects = new List<Project>();
        for (var i = 0; i < (volume ? 20 : 2); i++)
        {
            var project = Stable(new Project(i == 0 ? "Shared with members" : $"Isolated {i}", "Synthetic baseline", "FIX" + (char)('A' + i), User(i == 0 ? "owner" : "outsider")), i == 0 ? "project-shared" : $"project-{i}");
            foreach (var status in project.Statuses) Stable(status, $"status-{i}-{status.Order}");
            if (i == 0)
            {
                foreach (var pair in new[] { ("guest", MemberRole.Guest), ("member", MemberRole.Member), ("supervisor", MemberRole.Supervisor), ("removed", MemberRole.Member) })
                    Stable(project.AddMember(pair.Item1, pair.Item2), pair.Item1 + "-membership");
                project.RemoveMember("removed");
            }
            Stable(project.AddSprint("Baseline sprint", "Synthetic goal"), $"sprint-{i}");
            db.Projects.Add(project);
            projects.Add(project);
        }
        var tickets = new List<Ticket>();
        for (var i = 0; i < (volume ? 10000 : 4); i++)
        {
            var project = projects[i % projects.Count];
            var ticket = Stable(new Ticket(project.ConsumeNextTicketNumber(), $"Fixture ticket {i:00000}", "Synthetic content", TicketType.Task, CardPriority.Medium, project, project.GetDefaultStatus(), project.OwnerId), $"ticket-{i}");
            if (i % 2 == 0) ticket.MoveToSprint(project.Sprints.Single());
            ticket.Assign(project.OwnerId);
            Stable(ticket, $"ticket-{i}");
            tickets.Add(ticket);
            db.Tickets.Add(ticket);
        }
        var board = Stable(new Board("Legacy baseline", "Synthetic board", User("owner")), "board");
        var column = Stable(board.AddColumn("To do"), "column");
        var card = Stable(column.AddCard("Legacy card", "Preserve this card", "member"), "card");
        board.AddMember("member", MemberRole.Member);
        db.Boards.Add(board);
        var comment = Stable(Comment.CreateForTicket("Synthetic ticket comment", "member", tickets[0].Id), "ticket-comment");
        db.Comments.AddRange(comment, Stable(Comment.Create("Synthetic card comment", "member", card), "card-comment"));
        Directory.CreateDirectory(uploads);
        foreach (var kind in new[] { "ticket", "comment", "board" })
        {
            var path = kind + ".txt";
            await File.WriteAllTextAsync(Path.Combine(uploads, path), "fixture\n");
            var attachment = kind switch
            {
                "ticket" => Attachment.ForTicket(path, path, "text/plain", 8, "owner", tickets[0].Id),
                "comment" => Attachment.ForComment(path, path, "text/plain", 8, "member", comment.Id),
                _ => Attachment.ForBoard(path, path, "text/plain", 8, "owner", board.Id)
            };
            db.Attachments.Add(Stable(attachment, "attachment-" + kind));
        }
        // Normalize dates and generated membership identifiers after aggregate operations.
        foreach (var project in projects) Stable(project, project.Id == SharedProjectId ? "project-shared" : $"project-{projects.IndexOf(project)}");
        foreach (var membership in board.Members) Stable(membership, "board-member-" + membership.UserId);
        Stable(board, "board"); Stable(column, "column");
        await db.SaveChangesAsync();
    }
}
