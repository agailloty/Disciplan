using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddUserInvitations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "UserInvitations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    Token = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 64, nullable: false),
                    Email = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 256, nullable: true),
                    InvitedByUserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 450, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    IsUsed = table.Column<bool>(type: migrationBuilder.IsPostgres() ? null : "INTEGER", nullable: false),
                    UsedByUserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    UsedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserInvitations", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserInvitations_Token",
                table: "UserInvitations",
                column: "Token",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserInvitations");
        }
    }
}
