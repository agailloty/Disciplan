using Disciplaner.Application.DTOs.Card;

namespace Disciplaner.Web.Client.Services;

/// <summary>
/// Scoped service that holds the current drag-and-drop state.
/// Kept separate from UI components so no Blazor rendering logic leaks into business concerns.
/// </summary>
public sealed class KanbanDragState
{
    /// <summary>The card currently being dragged, or null when no drag is active.</summary>
    public CardDto? DraggedCard { get; private set; }

    /// <summary>The column the dragged card originated from.</summary>
    public Guid? SourceColumnId { get; private set; }

    public bool IsDragging => DraggedCard is not null;

    public void Begin(CardDto card, Guid sourceColumnId)
    {
        DraggedCard = card;
        SourceColumnId = sourceColumnId;
    }

    public (CardDto Card, Guid SourceColumnId)? End()
    {
        if (DraggedCard is null) return null;
        var result = (DraggedCard, SourceColumnId!.Value);
        DraggedCard = null;
        SourceColumnId = null;
        return result;
    }

    public void Cancel()
    {
        DraggedCard = null;
        SourceColumnId = null;
    }
}
