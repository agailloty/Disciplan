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
}
