namespace Disciplaner.Domain.Interfaces;

public interface IUnitOfWork
{
    IBoardRepository Boards { get; }
    IColumnRepository Columns { get; }
    ICardRepository Cards { get; }
    ICommentRepository Comments { get; }
    IUserRepository Users { get; }
    IProjectRepository Projects { get; }
    ISprintRepository Sprints { get; }
    ITicketRepository Tickets { get; }
    ILabelRepository Labels { get; }
    ISavedViewRepository SavedViews { get; }
    ITicketHistoryRepository TicketHistory { get; }
    IBoardMemberRepository BoardMembers { get; }
    IProjectMemberRepository ProjectMembers { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
