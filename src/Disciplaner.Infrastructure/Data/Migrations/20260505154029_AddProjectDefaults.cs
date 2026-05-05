using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddProjectDefaults : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DefaultAssigneePolicy",
                table: "Projects",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "DefaultTicketType",
                table: "Projects",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DefaultAssigneePolicy",
                table: "Projects");

            migrationBuilder.DropColumn(
                name: "DefaultTicketType",
                table: "Projects");
        }
    }
}
