using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMcpTokens : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "McpTokens",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    UserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 450, nullable: false),
                    Name = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 100, nullable: false),
                    Scopes = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 20, nullable: false),
                    TokenHash = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 44, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    LastUsedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    RevokedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    ExpiresAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_McpTokens", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_McpTokens_TokenHash",
                table: "McpTokens",
                column: "TokenHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_McpTokens_UserId",
                table: "McpTokens",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "McpTokens");
        }
    }
}
