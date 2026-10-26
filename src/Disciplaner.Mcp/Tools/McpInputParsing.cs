using Disciplaner.Domain.Enums;
using ModelContextProtocol;
using System.Globalization;

namespace Disciplaner.Mcp.Tools;

/// <summary>Parses LLM-friendly tool arguments (enum names, dates) with actionable errors.</summary>
public static class McpInputParsing
{
    public static TicketType ParseTicketType(string? value, TicketType? fallback = null)
    {
        if (value is null) return fallback ?? TicketType.Task;
        if (Enum.TryParse<TicketType>(value, ignoreCase: true, out var type)) return type;
        throw new McpException($"'{value}' is not a valid ticket type. Valid values: {string.Join(", ", Enum.GetNames<TicketType>())}.");
    }

    public static CardPriority ParsePriority(string? value, CardPriority? fallback = null)
    {
        if (value is null) return fallback ?? CardPriority.Medium;
        if (Enum.TryParse<CardPriority>(value, ignoreCase: true, out var priority)) return priority;
        throw new McpException($"'{value}' is not a valid priority. Valid values: {string.Join(", ", Enum.GetNames<CardPriority>())}.");
    }

    /// <summary>Accepts a date ("2026-03-31") or a full ISO 8601 datetime; returns UTC.</summary>
    public static DateTime ParseDate(string? value, string argumentName)
    {
        if (string.IsNullOrWhiteSpace(value) || !DateTime.TryParse(value, null, DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal, out var date))
            throw new McpException($"'{argumentName}' must be a date in ISO 8601 format, e.g. '2026-03-31'.");
        return date;
    }
}
