#!/bin/bash
# Layout de CYBorg TUI: default (Interfaz de Mando Principal)
# Estructura de 3 zonas: Cabecera, Cuerpo Principal y Pie de Página.

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi

SCRIPT_DIR=$(dirname "$(dirname "$0")")

# --- Panel del Ejecutor (en una ventana oculta) ---
# Se lanza como un demonio en una ventana no visible (-d) y con nombre.
tmux new-window -d -n "Executor" "bash $SCRIPT_DIR/panel_ejecutor.sh '$SESSION_DIR'"

# --- Ventana Principal (visible) ---

# La ventana principal inicia con un solo panel (índice 0)

# 1. Crear la división para la CABECERA.
# Dividir el panel 0 verticalmente, dejando 1 línea en la parte superior (-l 1).
# El panel 0 se convierte en la cabecera, el nuevo panel (1) en el resto del cuerpo.
tmux split-window -v -b -l 1

# 2. Crear la división para el PIE DE PÁGINA.
# Seleccionar el panel del cuerpo (1) y dividirlo de nuevo, dejando 1 línea en la parte inferior.
# El panel 1 se convierte en el nuevo cuerpo principal, y el nuevo panel (2) será el pie.
tmux select-pane -t 1
tmux split-window -v -l 1

# --- Ahora, construir el layout del CUERPO PRINCIPAL en el panel 1 ---
tmux select-pane -t 1
# Dividir el cuerpo horizontalmente (40% para el panel de control).
# El panel 1 se convierte en el control (izquierda), y el nuevo panel (3) será el área de visores (derecha).
tmux split-window -h -p 40

# Seleccionar el área de visores (3) y dividirla verticalmente (50%).
# El panel 3 se convierte en el visor superior, y el nuevo panel (4) en el área inferior.
tmux select-pane -t 3
tmux split-window -v -p 50

# Seleccionar el área inferior de visores (4) y dividirla verticalmente (50%).
# El panel 4 se convierte en el visor del medio, y el nuevo panel (5) en el visor inferior.
tmux select-pane -t 4
tmux split-window -v -p 50


# --- Asignar los scripts a cada panel por su índice final y correcto ---
# La numeración final de los paneles después de todas las divisiones es:
# 0: Cabecera (superior)
# 2: Pie de Página (inferior)
# 1: Cuerpo - Izquierda (Control)
# 3: Cuerpo - Superior Derecha (Actividad)
# 4: Cuerpo - Medio Derecha (Hallazgos)
# 5: Cuerpo - Inferior Derecha (Razonamiento)

# Panel 0: Cabecera
tmux respawn-pane -t 0 "bash $SCRIPT_DIR/_panel_header.sh '$SESSION_DIR'"

# Panel 2: Pie de Página
tmux respawn-pane -t 2 "bash $SCRIPT_DIR/_panel_footer.sh '$SESSION_DIR'"

# --- Paneles del Cuerpo Principal ---
# Panel 1: Panel de Control
tmux respawn-pane -t 1 "bash $SCRIPT_DIR/panel_control.sh '$SESSION_DIR'"

# Panel 3: Visor de Actividad (superior-derecha)
tmux respawn-pane -t 3 "bash $SCRIPT_DIR/panel_visor_actividad.sh '$SESSION_DIR'"

# Panel 4: Visor de Hallazgos (medio-derecha)
tmux respawn-pane -t 4 "bash $SCRIPT_DIR/panel_visor_hallazgos.sh '$SESSION_DIR'"

# Panel 5: Visor de Razonamiento IA (inferior-derecha)
tmux respawn-pane -t 5 "bash $SCRIPT_DIR/panel_visor_razonamiento.sh '$SESSION_DIR'"


# Seleccionar el panel de control por defecto para que el foco del usuario esté ahí al inicio
tmux select-pane -t 1