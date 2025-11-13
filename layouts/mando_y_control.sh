#!/bin/bash
# CYBorg v2.5 - Layout Principal: Mando y Control

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    tmux display-message "Error Crítico: No se ha proporcionado un directorio de sesión al layout."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")/..

# --- CREACIÓN DE LA ESTRUCTURA DE PANELES ---

# 1. Crear el Panel 0 (Título)
tmux split-window -v -l 4
tmux send-keys -t 0 "bash $SCRIPT_DIR/_panel_title.sh \"$SESSION_DIR\"" C-m

tmux select-pane -t 1

# 2. Dividir área de trabajo (derecha 1/3, izquierda 2/3)
tmux split-window -h -p 33

# 3. Dividir Columna Derecha -> Paneles 4 y 5
tmux select-pane -t 2
tmux split-window -v -p 50
tmux send-keys -t 2 "bash $SCRIPT_DIR/panel_visor_razonamiento.sh \"$SESSION_DIR\"" C-m
tmux send-keys -t 3 "bash $SCRIPT_DIR/panel_visor_actividad.sh \"$SESSION_DIR\"" C-m

# 4. Dividir Columna Izquierda -> Paneles 1, 2 y 3
tmux select-pane -t 1
# 4a. Crear Panel 1 (Control)
tmux split-window -v -l 7
tmux send-keys -t 1 "bash $SCRIPT_DIR/panel_control.sh \"$SESSION_DIR\"" C-m

# 4b. Dividir área restante -> Paneles 2 y 3
tmux select-pane -t 2
tmux split-window -h -p 50
tmux select-pane -t 2; tmux set-option -p pane-name "panel_tareas"
tmux send-keys -t 2 "bash $SCRIPT_DIR/panel_visor_tareas.sh \"$SESSION_DIR\"" C-m
tmux select-pane -t 3; tmux set-option -p pane-name "panel_hallazgos"
tmux send-keys -t 3 "bash $SCRIPT_DIR/panel_visor_hallazgos.sh \"$SESSION_DIR\"" C-m

# --- FINALIZACIÓN ---
tmux rename-window -t "$(tmux display-message -p '#I')" "Mando y Control"
tmux select-pane -t 1
