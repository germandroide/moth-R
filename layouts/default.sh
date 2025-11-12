#!/bin/bash
# CYBorg v2.5 - Layout por Defecto de la TUI (Cyber Commander)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    tmux display-message "Error Crítico: No se ha proporcionado un directorio de sesión al layout."
    sleep 5
    exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")/..

# --- CREACIÓN DE LA ESTRUCTURA DE 3 ZONAS ---

# 1. Dividir la ventana principal en 3 filas: Cabecera, Cuerpo y Pie de Página.
#    - Cabecera: 2 filas de alto, fija.
#    - Cuerpo: El resto del espacio, flexible.
#    - Pie de Página: 1 fila de alto, fija.
tmux split-window -v -l 2
tmux split-window -v -l 1

# 2. Lanzar los scripts de cabecera y pie de página en sus respectivos paneles.
#    - El panel 0 (arriba) será la cabecera.
#    - El panel 2 (abajo) será el pie de página.
tmux select-pane -t 0
tmux send-keys "bash $SCRIPT_DIR/_panel_header.sh \"$SESSION_DIR\"" C-m

tmux select-pane -t 2
tmux send-keys "bash $SCRIPT_DIR/_panel_footer.sh \"$SESSION_DIR\"" C-m

# 3. Seleccionar el panel del cuerpo (panel 1) para la subdivisión.
tmux select-pane -t 1

# --- CREACIÓN DEL LAYOUT INTERNO (CUERPO) ---
# Ahora, todo lo que hagamos se aplicará solo al panel del cuerpo.
# Este es el layout de la imagen 'paneles.png'.

# 1. Dividir el cuerpo en dos columnas: 67% para la izquierda, 33% para la derecha.
tmux split-window -h -p 33

# 2. Subdividir la columna izquierda (ahora panel 1).
tmux select-pane -t 1
# 2a. Dividir horizontalmente: 7 líneas para el Panel de Control.
tmux split-window -v -l 7
# 2b. Seleccionar el panel inferior (ahora panel 2) y dividirlo 50/50 verticalmente.
tmux select-pane -t 2
tmux split-window -h -p 50

# 3. Subdividir la columna derecha (ahora panel 4).
tmux select-pane -t 4
# 3a. Dividirlo 50/50 horizontalmente.
tmux split-window -v -p 50


# --- LANZAMIENTO DE LOS PANELES DE LA APLICACIÓN ---
# Ahora que la estructura está creada, lanzamos los scripts correspondientes en cada panel.
# El mapeo de paneles puede cambiar, así que es útil verificar con `Ctrl+B, q`.

# Panel de Control (superior-izquierda)
tmux select-pane -t 1
tmux send-keys "bash $SCRIPT_DIR/panel_control.sh \"$SESSION_DIR\"" C-m
tmux select-pane -t 1; tmux rename-window -t "$(tmux display-message -p '#I')" "Mando y Control"


# Gestión de Tareas y Nodos (centro-izquierda)
tmux select-pane -t 2
# (Placeholder, de momento mostramos un visor de actividad)
tmux send-keys "bash $SCRIPT_DIR/panel_visor_actividad.sh \"$SESSION_DIR\"" C-m

# Hallazgos de Seguridad (abajo-izquierda)
tmux select-pane -t 3
tmux send-keys "bash $SCRIPT_DIR/panel_visor_hallazgos.sh \"$SESSION_DIR\"" C-m

# Registro de Razonamiento (superior-derecha)
tmux select-pane -t 4
tmux send-keys "bash $SCRIPT_DIR/panel_visor_razonamiento.sh \"$SESSION_DIR\"" C-m

# Registro de Actividad (inferior-derecha)
tmux select-pane -t 5
tmux send-keys "bash $SCRIPT_DIR/panel_visor_actividad.sh \"$SESSION_DIR\"" C-m


# Devolver el foco al panel de control para que el usuario pueda empezar a trabajar.
tmux select-pane -t 1
