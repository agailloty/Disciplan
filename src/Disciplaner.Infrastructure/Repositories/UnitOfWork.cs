using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

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
        ICalendarTokenRepository calendarTokens)
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
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);

    public async Task<T> InTransactionAsync<T>(Func<Task<T>> action, CancellationToken cancellationToken = default)
    {
        // SQLite's immediate transaction serializes writers before the aggregate is read.
        if (_context.Database.CurrentTransaction is not null) return await action();
        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var result = await action();
            await transaction.CommitAsync(cancellationToken);
            return result;
        }
        catch
        {
            await transaction.RollbackAsync(CancellationToken.None);
            _context.ChangeTracker.Clear();
            throw;
        }
    }
}
