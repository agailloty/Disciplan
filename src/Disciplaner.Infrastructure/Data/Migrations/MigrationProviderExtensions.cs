using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using Microsoft.EntityFrameworkCore.Migrations.Operations.Builders;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations;

internal static class MigrationProviderExtensions
{
    public static bool IsPostgres(this MigrationBuilder migrationBuilder)
        => migrationBuilder.ActiveProvider.Contains("PostgreSQL", StringComparison.OrdinalIgnoreCase);

    public static OperationBuilder<AddColumnOperation> AsAutoIncrement(
        this OperationBuilder<AddColumnOperation> operation,
        MigrationBuilder migrationBuilder)
    {
        if (migrationBuilder.IsPostgres())
        {
            return operation.Annotation(
                "Npgsql:ValueGenerationStrategy",
                NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);
        }

        return operation.Annotation("Sqlite:Autoincrement", true);
    }
}
