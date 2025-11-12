#!/bin/bash
# CYBorg v2.5 - Script para Cambiar la Vista de Paneles

NEW_VIEW_NAME=$1
SESSION_DIR=$2

if [ -z "$NEW_VIEW_NAME" ] || [ -z "$SESSION_DIR" ]; then
    tmux display-message "Error: Faltan argumentos para cambiar la vista."
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LAYOUT_FILE="$SCRIPT_DIR/layouts/${NEW_VIEW_NAME}.sh"

if [ ! -f "$LAYOUT_FILE" ]; then
    tmux display-message "Error: No se encontró el layout de vista '$NEW_VIEW_NAME'."
    exit 1
fi

# --- LÓGICA DE CAMBIO DE VISTA ---

# El panel "cuerpo" es siempre el panel número 1 en nuestra estructura de 3 zonas.
BODY_PANE_ID=1

# 1. Matar todos los paneles que están DENTRO del panel del cuerpo.
#    `tmux list-panes -s -F '#{pane_id}' -t $BODY_PANE_ID` lista todos los sub-paneles.
#    El `grep -v` es para evitar que se mate a sí mismo.
for pane in $(tmux list-panes -s -F '#{pane_id}' -t $BODY_PANE_ID | grep -v "^$BODY_PANE_ID\$"); do
    tmux kill-pane -t "$pane"
done

# 2. Una vez que el panel del cuerpo está "limpio" (sin subdivisiones),
#    ejecutamos el nuevo script de layout DENTRO de él.
#    Tmux es lo suficientemente inteligente como para reemplazar el proceso
#    actual del panel con el nuevo layout.
#    Pasamos el ID del panel objetivo al script del layout.
tmux send-keys -t $BODY_PANE_ID "bash '$LAYOUT_FILE' '$SESSION_DIR' '$BODY_PANE_ID'" C-m

tmux display-message "Vista cambiada a: $NEW_VIEW_NAME"
