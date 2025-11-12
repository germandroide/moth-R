#!/bin/bash
# CYBorg v2.5 - Layout de Vista: Gestión del Clúster

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    tmux display-message "Error Crítico: No se ha proporcionado un directorio de sesión al layout."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")/..
TARGET_PANE_ID=$2 # El ID del panel del "cuerpo" donde se cargará este layout.

# --- CREACIÓN DEL LAYOUT ---
# Esta vista tiene dos paneles verticales (40%/60%).

# 1. Dividir el panel objetivo en dos, verticalmente.
tmux split-window -t "$TARGET_PANE_ID" -h -p 60

# --- LANZAMIENTO DE PANELES ---

# Panel Izquierdo: Lista de Workers
# (Placeholder)
tmux select-pane -t "$TARGET_PANE_ID"
tmux send-keys "echo 'Lista de Workers (Próximamente)...'; sleep infinity" C-m

# Panel Derecho: Log de Actividad del Clúster
# (Usaremos un visor de actividad por ahora, en el futuro será un visor específico)
tmux select-pane -t 2 # Asumiendo que el panel del cuerpo era 1, el nuevo es 2.
tmux send-keys "bash $SCRIPT_DIR/panel_visor_actividad.sh \"$SESSION_DIR\"" C-m

# Cambiar el nombre de la ventana para reflejar la vista actual.
tmux rename-window -t "$(tmux display-message -p '#I')" "Gestión del Clúster"

# Devolvemos el foco al panel principal de la vista.
tmux select-pane -t "$TARGET_PANE_ID"
