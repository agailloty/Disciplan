using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Disciplaner.Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddLabels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Labels",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 50, nullable: false),
                    Color = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Labels", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "LabelBoards",
                columns: table => new
                {
                    BoardsId = table.Column<Guid>(type: "TEXT", nullable: false),
                    LabelsId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LabelBoards", x => new { x.BoardsId, x.LabelsId });
                    table.ForeignKey(
                        name: "FK_LabelBoards_Boards_BoardsId",
                        column: x => x.BoardsId,
                        principalTable: "Boards",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_LabelBoards_Labels_LabelsId",
                        column: x => x.LabelsId,
                        principalTable: "Labels",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "LabelTickets",
                columns: table => new
                {
                    LabelsId = table.Column<Guid>(type: "TEXT", nullable: false),
                    TicketsId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LabelTickets", x => new { x.LabelsId, x.TicketsId });
                    table.ForeignKey(
                        name: "FK_LabelTickets_Labels_LabelsId",
                        column: x => x.LabelsId,
                        principalTable: "Labels",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_LabelTickets_Tickets_TicketsId",
                        column: x => x.TicketsId,
                        principalTable: "Tickets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_LabelBoards_LabelsId",
                table: "LabelBoards",
                column: "LabelsId");

            migrationBuilder.CreateIndex(
                name: "IX_LabelTickets_TicketsId",
                table: "LabelTickets",
                column: "TicketsId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "LabelBoards");

            migrationBuilder.DropTable(
                name: "LabelTickets");

            migrationBuilder.DropTable(
                name: "Labels");
        }
    }
}
