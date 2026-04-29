using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Data;

namespace Disciplaner.Infrastructure.Repositories;

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public IBoardRepository Boards { get; }
    public IColumnRepository Columns { get; }
    public ICardRepository Cards { get; }
    public IUserRepository Users { get; }

    public UnitOfWork(
        ApplicationDbContext context,
        IBoardRepository boards,
        IColumnRepository columns,
        ICardRepository cards,
        IUserRepository users)
    {
        _context = context;
        Boards = boards;
        Columns = columns;
        Cards = cards;
        Users = users;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);
}
