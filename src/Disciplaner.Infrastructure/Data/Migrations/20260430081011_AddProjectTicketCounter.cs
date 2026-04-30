using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectTicketCounter : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "NextTicketNumber",
                table: "Projects",
                type: "INTEGER",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.CreateIndex(
                name: "IX_Projects_Key",
                table: "Projects",
                column: "Key",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Projects_Key",
                table: "Projects");

            migrationBuilder.DropColumn(
                name: "NextTicketNumber",
                table: "Projects");
        }
    }
}
