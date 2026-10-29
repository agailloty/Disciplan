using System.Data;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace Disciplaner.Infrastructure.Repositories;

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public IAttachmentRepository Attachments { get; }
    public IBoardRepository Boards { get; }
    public IColumnRepository Columns { get; }
    public ICardRepository Cards { get; }
    public ICommentRepository Comments { get; }
    public IUserRepository Users { get; }
    public IProjectRepository Projects { get; }
    public ISprintRepository Sprints { get; }
    public ITicketRepository Tickets { get; }
    public ILabelRepository Labels { get; }
    public ISavedViewRepository SavedViews { get; }
    public ITicketHistoryRepository TicketHistory { get; }
    public IBoardMemberRepository BoardMembers { get; }
    public IProjectMemberRepository ProjectMembers { get; }
    public ICalendarTokenRepository CalendarTokens { get; }
    public IMcpTokenRepository McpTokens { get; }

    public UnitOfWork(
        ApplicationDbContext context,
        IAttachmentRepository attachments,
        IBoardRepository boards,
        IColumnRepository columns,
        ICardRepository cards,
        ICommentRepository comments,
        IUserRepository users,
        IProjectRepository projects,
        ISprintRepository sprints,
        ITicketRepository tickets,
        ILabelRepository labels,
        ISavedViewRepository savedViews,
        ITicketHistoryRepository ticketHistory,
        IBoardMemberRepository boardMembers,
        IProjectMemberRepository projectMembers,
        ICalendarTokenRepository calendarTokens,
        IMcpTokenRepository mcpTokens)
    {
        _context = context;
        Attachments = attachments;
        Boards = boards;
        Columns = columns;
        Cards = cards;
        Comments = comments;
        Users = users;
        Projects = projects;
        Sprints = sprints;
        Tickets = tickets;
        Labels = labels;
        SavedViews = savedViews;
        TicketHistory = ticketHistory;
        BoardMembers = boardMembers;
        ProjectMembers = projectMembers;
        CalendarTokens = calendarTokens;
        McpTokens = mcpTokens;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);

    public async Task<T> InTransactionAsync<T>(Func<Task<T>> action, CancellationToken cancellationToken = default)
    {
        if (_context.Database.CurrentTransaction is not null)
            return await action();

        var isPostgres = _context.Database.ProviderName?.Contains("PostgreSQL", StringComparison.OrdinalIgnoreCase) == true;
        const int maxRetries = 6;

        for (var attempt = 1; ; attempt++)
        {
            await using var transaction = isPostgres
                ? await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable, cancellationToken)
                : await _context.Database.BeginTransactionAsync(cancellationToken);

            try
            {
                var result = await action();
                await transaction.CommitAsync(cancellationToken);
                return result;
            }
            catch (Exception ex) when (attempt < maxRetries && IsTransientConflict(ex))
            {
                await transaction.RollbackAsync(CancellationToken.None);
                _context.ChangeTracker.Clear();
                await Task.Delay(TimeSpan.FromMilliseconds(15 * attempt), cancellationToken);
            }
            catch
            {
                await transaction.RollbackAsync(CancellationToken.None);
                _context.ChangeTracker.Clear();
                throw;
            }
        }
    }

    private static bool IsTransientConflict(Exception ex)
    {
        if (ex is DbUpdateConcurrencyException)
            return true;

        for (var curr = ex; curr is not null; curr = curr.InnerException)
        {
            // PostgreSQL SQLSTATE 40001 = serialization_failure, 40P01 = deadlock_detected
            if (curr is PostgresException pg && (pg.SqlState == PostgresErrorCodes.SerializationFailure || pg.SqlState == PostgresErrorCodes.DeadlockDetected))
                return true;
        }

        return false;
    }
}
