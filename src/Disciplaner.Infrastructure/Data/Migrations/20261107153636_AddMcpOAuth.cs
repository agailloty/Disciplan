using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMcpOAuth : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "McpOAuthAuthorizationCodes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    CodeHash = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 128, nullable: false),
                    ClientId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 100, nullable: false),
                    UserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 450, nullable: false),
                    RedirectUri = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 2000, nullable: false),
                    Scope = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 50, nullable: false),
                    CodeChallenge = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 256, nullable: false),
                    CodeChallengeMethod = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    UsedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_McpOAuthAuthorizationCodes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "McpOAuthClients",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    ClientId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 100, nullable: false),
                    ClientName = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 200, nullable: false),
                    ClientSecretHash = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 128, nullable: true),
                    RedirectUrisJson = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    GrantTypesJson = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 500, nullable: false),
                    ResponseTypesJson = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 200, nullable: false),
                    TokenEndpointAuthMethod = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 50, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_McpOAuthClients", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "McpOAuthTokens",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    ClientId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 100, nullable: false),
                    UserId = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 450, nullable: false),
                    Scope = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 50, nullable: false),
                    AccessTokenHash = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 128, nullable: false),
                    RefreshTokenHash = table.Column<string>(type: migrationBuilder.IsPostgres() ? null : "TEXT", maxLength: 128, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    AccessTokenExpiresAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: false),
                    RefreshTokenExpiresAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    LastUsedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true),
                    RevokedAt = table.Column<DateTime>(type: migrationBuilder.IsPostgres() ? null : "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_McpOAuthTokens", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_McpOAuthAuthorizationCodes_CodeHash",
                table: "McpOAuthAuthorizationCodes",
                column: "CodeHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_McpOAuthClients_ClientId",
                table: "McpOAuthClients",
                column: "ClientId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_McpOAuthTokens_AccessTokenHash",
                table: "McpOAuthTokens",
                column: "AccessTokenHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_McpOAuthTokens_RefreshTokenHash",
                table: "McpOAuthTokens",
                column: "RefreshTokenHash");

            migrationBuilder.CreateIndex(
                name: "IX_McpOAuthTokens_UserId",
                table: "McpOAuthTokens",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "McpOAuthAuthorizationCodes");

            migrationBuilder.DropTable(
                name: "McpOAuthClients");

            migrationBuilder.DropTable(
                name: "McpOAuthTokens");
        }
    }
}
