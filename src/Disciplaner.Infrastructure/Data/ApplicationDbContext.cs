using Disciplaner.Domain.Entities;
using Disciplaner.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Disciplaner.Infrastructure.Data;

public sealed class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Board> Boards => Set<Board>();
    public DbSet<Column> Columns => Set<Column>();
    public DbSet<Card> Cards => Set<Card>();
    public DbSet<Comment> Comments => Set<Comment>();
    public DbSet<Attachment> Attachments => Set<Attachment>();
    public DbSet<Project> Projects => Set<Project>();
    public DbSet<Sprint> Sprints => Set<Sprint>();
    public DbSet<Ticket> Tickets => Set<Ticket>();
    public DbSet<TicketStatus> TicketStatuses => Set<TicketStatus>();
    public DbSet<Label> Labels => Set<Label>();
    public DbSet<SavedView> SavedViews => Set<SavedView>();
    public DbSet<TicketHistory> TicketHistories => Set<TicketHistory>();
    public DbSet<UserInvitation> UserInvitations => Set<UserInvitation>();
    public DbSet<BoardMember> BoardMembers => Set<BoardMember>();
    public DbSet<ProjectMember> ProjectMembers => Set<ProjectMember>();
    public DbSet<CalendarToken> CalendarTokens => Set<CalendarToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Domain.User is not mapped by EF — authentication is handled by ApplicationUser (Identity).
        // Repositories use UserManager<ApplicationUser> and convert to Domain.User.
        modelBuilder.Ignore<User>();

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}
