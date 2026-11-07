using Disciplaner.Domain.Entities;
using Disciplaner.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

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
    public DbSet<McpToken> McpTokens => Set<McpToken>();
    public DbSet<McpOAuthClient> McpOAuthClients => Set<McpOAuthClient>();
    public DbSet<McpOAuthAuthorizationCode> McpOAuthAuthorizationCodes => Set<McpOAuthAuthorizationCode>();
    public DbSet<McpOAuthToken> McpOAuthTokens => Set<McpOAuthToken>();

    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        base.ConfigureConventions(configurationBuilder);

        configurationBuilder.Properties<DateTime>()
            .HaveConversion<UtcValueConverter>();
        configurationBuilder.Properties<DateTime?>()
            .HaveConversion<NullableUtcValueConverter>();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Domain.User is not mapped by EF — authentication is handled by ApplicationUser (Identity).
        // Repositories use UserManager<ApplicationUser> and convert to Domain.User.
        modelBuilder.Ignore<User>();

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }

    private sealed class UtcValueConverter() : ValueConverter<DateTime, DateTime>(
        v => v.Kind == DateTimeKind.Utc ? v : (v.Kind == DateTimeKind.Local ? v.ToUniversalTime() : DateTime.SpecifyKind(v, DateTimeKind.Utc)),
        v => DateTime.SpecifyKind(v, DateTimeKind.Utc));

    private sealed class NullableUtcValueConverter() : ValueConverter<DateTime?, DateTime?>(
        v => !v.HasValue ? null : (v.Value.Kind == DateTimeKind.Utc ? v.Value : (v.Value.Kind == DateTimeKind.Local ? v.Value.ToUniversalTime() : DateTime.SpecifyKind(v.Value, DateTimeKind.Utc))),
        v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : null);
}
