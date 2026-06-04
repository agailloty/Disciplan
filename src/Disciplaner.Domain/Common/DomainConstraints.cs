namespace Disciplaner.Domain.Common;

public static class DomainConstraints
{
    public static class Board
    {
        public const int NameMaxLength = 100;
        public const int DescriptionMaxLength = 500;
        public const int MaxColumns = 20;
    }

    public static class Column
    {
        public const int NameMaxLength = 50;
        public const int MaxCards = 100;
    }

    public static class Card
    {
        public const int TitleMaxLength = 200;
        public const int DescriptionMaxLength = 2000;
    }

    public static class User
    {
        public const int DisplayNameMaxLength = 50;
    }

    public static class Comment
    {
        public const int ContentMaxLength = 2000;
    }

    public static class Project
    {
        public const int NameMaxLength = 100;
        public const int DescriptionMaxLength = 500;
        public const int KeyMaxLength = 10;
    }

    public static class TicketStatus
    {
        public const int NameMaxLength = 50;
    }

    public static class Ticket
    {
        public const int TitleMaxLength = 250;
        public const int DescriptionMaxLength = 10000;
    }

    public static class Sprint
    {
        public const int NameMaxLength = 100;
        public const int GoalMaxLength = 500;
    }

    public static class Label
    {
        public const int NameMaxLength = 50;
        public const int ColorMaxLength = 20;
    }

    public static class SavedView
    {
        public const int NameMaxLength = 100;
        public const int DescriptionMaxLength = 500;
    }

    public static class Attachment
    {
        public const int FileNameMaxLength = 255;
        public const int ContentTypeMaxLength = 100;
        public const int StoragePathMaxLength = 500;
    }

    public static class CalendarToken
    {
        /// <summary>40-char lowercase hex string produced by RandomNumberGenerator (20 bytes).</summary>
        public const int TokenLength = 40;
    }
}
