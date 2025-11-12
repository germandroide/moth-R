#!/bin/bash
# CYBorg v2.5 - Layout de Vista: Análisis de Hallazgos

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    tmux display-message "Error Crítico: No se ha proporcionado un directorio de sesión al layout."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")/..
TARGET_PANE_ID=$2 # El ID del panel del "cuerpo" donde se cargará este layout.

# --- CREACIÓN DEL LAYOUT ---
# Esta vista tiene dos paneles verticales (50%/50%).

# 1. Dividir el panel objetivo en dos, verticalmente.
tmux split-window -t "$TARGET_PANE_ID" -h -p 50

# --- LANZAMIENTO DE PANELES ---

# Panel Izquierdo: Lista de Hallazgos
# (Por ahora, un placeholder. En el futuro, será un script interactivo)
tmux select-pane -t "$TARGET_PANE_ID"
tmux send-keys "echo 'Lista de Hallazgos (Próximamente)...'; sleep infinity" C-m

# Panel Derecho: Detalle del Hallazgo
# (Usamos el visor de hallazgos estándar por ahora)
# El nuevo panel creado por split-window suele ser el siguiente en índice.
# Nota: Esta es una forma simple; una implementación más robusta podría
# capturar el ID del nuevo panel.
tmux select-pane -t 2 # Asumiendo que el panel del cuerpo era 1, el nuevo es 2.
tmux send-keys "bash $SCRIPT_DIR/panel_visor_hallazgos.sh \"$SESSION_DIR\"" C-m

# Cambiar el nombre de la ventana para reflejar la vista actual.
tmux rename-window -t "$(tmux display-message -p '#I')" "Análisis de Hallazgos"

# Devolvemos el foco al panel principal de la vista.
tmux select-pane -t "$TARGET_PANE_ID"
