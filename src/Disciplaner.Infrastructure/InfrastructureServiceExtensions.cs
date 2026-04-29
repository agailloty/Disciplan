using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Services;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace Disciplaner.Infrastructure;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        // Repositories (internal — only accessible via this extension)
        services.AddScoped<IBoardRepository, BoardRepository>();
        services.AddScoped<IColumnRepository, ColumnRepository>();
        services.AddScoped<ICardRepository, CardRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Application services
        services.AddScoped<IBoardService, BoardService>();
        services.AddScoped<IColumnService, ColumnService>();
        services.AddScoped<ICardService, CardService>();

        return services;
    }
}
