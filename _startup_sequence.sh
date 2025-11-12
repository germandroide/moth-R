#!/bin/bash
# CYBorg v2.5 - Secuencia de Arranque de la TUI (Cargador de Layouts)

SESSION_DIR=$1
LAYOUT_NAME=$2
TESTING_FLAG=$3 # Recibe el flag de testing
if [ -z "$LAYOUT_NAME" ]; then
    # Si no se proporciona un layout, no podemos hacer nada.
    tmux display-message "Error Crítico: No se especificó un layout para cargar."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
LAYOUTS_DIR="$SCRIPT_DIR/layouts"
LAYOUT_FILE_TO_LOAD="$LAYOUTS_DIR/${LAYOUT_NAME}.sh"

# --- CONFIGURACIÓN DE LA SESIÓN DE TMUX ---

# 1. Habilitar el soporte de ratón para una mejor UX (CRÍTICO para el menú contextual)
tmux set-option -g mouse on

# 2. Definir el menú contextual del clic derecho
# Este menú se mostrará cuando se haga clic derecho en cualquier panel.
# El comando 'respawn-pane' recargará el panel clicado ('-t "#{mouse_pane}"')
# con el script seleccionado.
tmux bind-key -T root MouseDown3Pane display-menu -T "Cargar Panel" -t "#{mouse_pane}" \
    "Panel de Control" "c" "respawn-pane -t '#{mouse_pane}' 'bash $SCRIPT_DIR/panel_control.sh \"$SESSION_DIR\"'" \
    "" \
    "Visor de Actividad" "a" "respawn-pane -t '#{mouse_pane}' 'bash $SCRIPT_DIR/panel_visor_actividad.sh \"$SESSION_DIR\"'" \
    "Visor de Hallazgos" "h" "respawn-pane -t '#{mouse_pane}' 'bash $SCRIPT_DIR/panel_visor_hallazgos.sh \"$SESSION_DIR\"'" \
    "Visor de Razonamiento IA" "r" "respawn-pane -t '#{mouse_pane}' 'bash $SCRIPT_DIR/panel_visor_razonamiento.sh \"$SESSION_DIR\"'" \
    "" \
    "Cerrar Menú" "q" ""


# 3. Seleccionar y ejecutar el script de layout
if [ -f "$LAYOUT_FILE_TO_LOAD" ]; then
    # Pasamos el flag de testing al script del layout (el wizard lo necesita)
    bash "$LAYOUT_FILE_TO_LOAD" "$SESSION_DIR" "$TESTING_FLAG"
else
    # Fallback de emergencia si el layout solicitado no existe
    tmux display-message "Error: No se encontró el script de layout '$LAYOUT_NAME'."
    sleep 5
    exit 1
fi

# 4. Esperar indefinidamente.
# Este es el paso CRÍTICO. Al evitar que este script termine, nos aseguramos
# de que la sesión de tmux no se cierre sola, incluso después de que el
# script de layout haya terminado su trabajo.
sleep infinity