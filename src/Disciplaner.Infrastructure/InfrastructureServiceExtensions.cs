using Disciplaner.Application.Interfaces;
using Disciplaner.Application.Services;
using Disciplaner.Domain.Interfaces;
using Disciplaner.Infrastructure.Repositories;
using Disciplaner.Infrastructure.Storage;
using Microsoft.Extensions.DependencyInjection;

namespace Disciplaner.Infrastructure;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services)
    {
        // Repositories (internal — only accessible via this extension)
        services.AddScoped<IAttachmentRepository, AttachmentRepository>();
        services.AddScoped<IBoardRepository, BoardRepository>();
        services.AddScoped<IColumnRepository, ColumnRepository>();
        services.AddScoped<ICardRepository, CardRepository>();
        services.AddScoped<ICommentRepository, CommentRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IUserInvitationRepository, UserInvitationRepository>();
        services.AddScoped<IProjectRepository, ProjectRepository>();
        services.AddScoped<ISprintRepository, SprintRepository>();
        services.AddScoped<ITicketRepository, TicketRepository>();
        services.AddScoped<ILabelRepository, LabelRepository>();
        services.AddScoped<ISavedViewRepository, SavedViewRepository>();
        services.AddScoped<ITicketHistoryRepository, TicketHistoryRepository>();
        services.AddScoped<IBoardMemberRepository, BoardMemberRepository>();
        services.AddScoped<IProjectMemberRepository, ProjectMemberRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Application services
        services.AddScoped<IAttachmentService, AttachmentService>();
        services.AddScoped<IBoardService, BoardService>();
        services.AddScoped<IColumnService, ColumnService>();
        services.AddScoped<ICardService, CardService>();
        services.AddScoped<ICommentService, CommentService>();
        services.AddScoped<IProjectService, ProjectService>();
        services.AddScoped<ISprintService, SprintService>();
        services.AddScoped<ITicketService, TicketService>();
        services.AddScoped<IActivityService, ActivityService>();
        services.AddScoped<ILabelService, LabelService>();
        services.AddScoped<ISavedViewService, SavedViewService>();
        services.AddScoped<ITicketHistoryService, TicketHistoryService>();
        services.AddScoped<IBoardMemberService, BoardMemberService>();
        services.AddScoped<IProjectMemberService, ProjectMemberService>();

        // File storage
        services.AddSingleton<IFileStorageService, LocalFileStorageService>();

        return services;
    }
}
