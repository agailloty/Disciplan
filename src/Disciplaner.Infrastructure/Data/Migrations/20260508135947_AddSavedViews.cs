using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddSavedViews : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SavedViews",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    Name = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    Description = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    IsVisibleOnHome = table.Column<bool>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: false),
                    DisplayOrder = table.Column<int>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: false),
                    UserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    ProjectId = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    StatusId = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    SprintId = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    Type = table.Column<int>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: true),
                    Priority = table.Column<int>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: true),
                    StatusCategory = table.Column<int>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: true),
                    OnlyAssignedToMe = table.Column<bool>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: false),
                    OnlyReportedByMe = table.Column<bool>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SavedViews", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SavedViews");
        }
    }
}
