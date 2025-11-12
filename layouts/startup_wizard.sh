#!/bin/bash
# Layout de CYBorg TUI: startup_wizard
# Interfaz inicial para la configuración de la auditoría.

# No necesita SESSION_DIR al principio, pero sí el flag de testing
TESTING_FLAG=$2
SCRIPT_DIR=$(dirname "$(dirname "$0")")

# --- Panel del Ejecutor (en una ventana oculta) ---
# Se crea pero no se usa hasta que la sesión esté configurada.
# Lo nombramos "Executor-Idle" para indicar su estado.
tmux new-window -d -n "Executor-Idle" "echo 'Esperando configuración de sesión...'; sleep infinity"

# --- Ventana Principal (visible) ---

# 1. Crear la división para la CABECERA.
tmux split-window -v -b -l 1

# 2. Crear la división para el PIE DE PÁGINA.
tmux select-pane -t 1
tmux split-window -v -l 1

# --- Asignar los scripts a cada panel por su índice ---
# 0: Cabecera
# 1: Cuerpo (Wizard)
# 2: Pie

# Panel 0: Cabecera (placeholder)
tmux respawn-pane -t 0 "bash $SCRIPT_DIR/_panel_header.sh ''"

# Panel 2: Pie de Página (estático)
tmux respawn-pane -t 2 "bash $SCRIPT_DIR/_panel_footer.sh ''" # No necesita session dir

# Panel 1: El Asistente de Configuración
# Le pasamos el flag de testing.
tmux respawn-pane -t 1 "bash $SCRIPT_DIR/_startup_wizard.sh '$TESTING_FLAG'"

# Seleccionar el panel del wizard para que el foco del usuario esté ahí
tmux select-pane -t 1