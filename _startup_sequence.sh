#!/bin/bash
# CYBorg v2.5 - Secuencia de Arranque de la TUI (Cargador de Layouts)

SESSION_DIR=$1
LAYOUT_NAME=$2
TESTING_FLAG=$3

if [ -z "$LAYOUT_NAME" ]; then
    tmux display-message "Error Crítico: No se especificó un layout para cargar."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LAYOUTS_DIR="$SCRIPT_DIR/layouts"
LAYOUT_FILE_TO_LOAD="$LAYOUTS_DIR/${LAYOUT_NAME}.sh"

# --- CONFIGURACIÓN DE LA SESIÓN DE TMUX ---

# 1. Habilitar el soporte de ratón para una mejor UX
tmux set-option -g mouse on

# 2. (Opcional) Definir menú contextual de clic derecho si se desea en el futuro.
# Por ahora, lo mantenemos simple.

# 3. Ejecutar el script de layout solicitado
if [ -f "$LAYOUT_FILE_TO_LOAD" ]; then
    # Pasamos los argumentos necesarios al script del layout.
    bash "$LAYOUT_FILE_TO_LOAD" "$SESSION_DIR" "$TESTING_FLAG"
else
    tmux display-message "Error: No se encontró el script de layout '$LAYOUT_NAME'."
    sleep 5
    exit 1
fi

# 4. Mantener la sesión viva
# Este script no debe terminar, o la sesión de tmux se cerrará.
sleep infinity
