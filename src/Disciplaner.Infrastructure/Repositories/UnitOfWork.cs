using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;

namespace Disciplaner.Infrastructure.Repositories;

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

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

    public UnitOfWork(
        ApplicationDbContext context,
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
        ITicketHistoryRepository ticketHistory)
    {
        _context = context;
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
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);
}
