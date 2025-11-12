#!/bin/bash
# CYBorg v2.5 - Mecanismo de Conmutación a Panel de Diálogo

MODE=$1 # 'open' o 'close'
DIALOG_SCRIPT=$2 # El script a ejecutar en el panel de diálogo
SESSION_DIR=$3

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Fichero temporal para guardar el estado del layout
LAYOUT_STATE_FILE="/tmp/cyborg_layout_state_$$"

# --- MODO APERTURA ---
if [ "$MODE" = "open" ]; then
    # 1. Encontrar los paneles por su nombre
    PANE_TAREAS_ID=$(tmux list-panes -F "#{pane_id}:#{pane_name}" | grep "panel_tareas" | cut -d: -f1)
    PANE_HALLAZGOS_ID=$(tmux list-panes -F "#{pane_id}:#{pane_name}" | grep "panel_hallazgos" | cut -d: -f1)

    if [ -z "$PANE_TAREAS_ID" ] || [ -z "$PANE_HALLAZGOS_ID" ]; then
        tmux display-message "Error: No se pudieron encontrar los paneles para conmutar."
        exit 1
    fi

    # 2. Guardar el estado. Necesitamos el ID del panel que contiene a ambos.
    #    La forma más fiable es buscar el panel que está encima del panel de tareas.
    PARENT_PANE_ID=$(tmux list-panes -F "#{pane_id}" -f "#{pane_top}" | head -n 1) # Simplificación: asumimos que el panel 1 es el padre.

    # Guardamos el ID del panel padre para poder recrear la división.
    echo "PARENT_PANE_ID=$PARENT_PANE_ID" > "$LAYOUT_STATE_FILE"

    # 3. Matar los paneles
    tmux kill-pane -t "$PANE_TAREAS_ID"
    tmux kill-pane -t "$PANE_HALLAZGOS_ID"

    # 4. En el panel que queda (que ahora ocupa todo el espacio), lanzar el script de diálogo
    tmux send-keys -t "$PARENT_PANE_ID" "bash $DIALOG_SCRIPT \"$SESSION_DIR\"" C-m

    tmux display-message "Diálogo abierto. Ejecuta 'close' para restaurar."

# --- MODO CIERRE ---
elif [ "$MODE" = "close" ]; then
    if [ ! -f "$LAYOUT_STATE_FILE" ]; then
        tmux display-message "Error: No se encontró estado de layout para restaurar."
        exit 1
    fi
    source "$LAYOUT_STATE_FILE"

    # 1. Matar el panel de diálogo (que está en el PARENT_PANE_ID)
    #    No lo matamos, simplemente le enviamos el comando para que se re-divida.

    # 2. Recrear la división
    tmux split-window -t "$PARENT_PANE_ID" -h -p 50

    # 3. Relanzar los paneles originales
    #    Los nuevos paneles tendrán IDs diferentes, pero la estructura visual será la misma.
    tmux select-pane -t "$PARENT_PANE_ID"; tmux set-option -p pane-name "panel_tareas"
    tmux send-keys -t "$PARENT_PANE_ID" "bash $SCRIPT_DIR/panel_visor_tareas.sh \"$SESSION_DIR\"" C-m

    # Necesitamos una forma de seleccionar el nuevo panel creado
    NEW_PANE_ID=$(tmux list-panes -F "#{pane_id}" | tail -n 1)
    tmux select-pane -t "$NEW_PANE_ID"; tmux set-option -p pane-name "panel_hallazgos"
    tmux send-keys -t "$NEW_PANE_ID" "bash $SCRIPT_DIR/panel_visor_hallazgos.sh \"$SESSION_DIR\"" C-m

    # Limpiar
    rm "$LAYOUT_STATE_FILE"
    tmux display-message "Vista restaurada."
fi
