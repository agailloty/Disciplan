using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSavedViewStatusCategories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StatusCategory",
                table: "SavedViews");

            migrationBuilder.AddColumn<string>(
                name: "StatusCategories",
                table: "SavedViews",
                type: "TEXT",
                nullable: false,
                defaultValueSql: "'[]'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StatusCategories",
                table: "SavedViews");

            migrationBuilder.AddColumn<int>(
                name: "StatusCategory",
                table: "SavedViews",
                type: "INTEGER",
                nullable: true);
        }
    }
}
