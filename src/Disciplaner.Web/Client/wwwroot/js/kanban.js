// kanban.js — minimal JS interop for HTML5 Drag & Drop
// Blazor handles all state; JS only sets dataTransfer (required by browser API)
// and prevents default dragover so the browser shows the "drop allowed" cursor.

window.kanban = {
    /**
     * Called on dragstart. dataTransfer.effectAllowed is required so the browser
     * shows a move cursor and fires the drop event on the target.
     */
    setDragData: function (cardId) {
        // cardId is passed so browsers that expose dataTransfer data can read it.
        // We store it on the event via a module-level variable because Blazor
        // does not give us direct access to the DragEvent object.
        window._kanbanDragCardId = cardId;
    },

    /**
     * Called on dragover of a drop zone. Must call preventDefault() so that
     * the browser fires the 'drop' event. Without this the drop is cancelled.
     */
    allowDrop: function (element) {
        if (element) {
            element.addEventListener('dragover', e => e.preventDefault(), { passive: false });
        }
    }
};
