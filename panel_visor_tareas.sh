#!/bin/bash
# CYBorg v2.5 - Panel 2: Visor de Tareas y Nodos

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi
source "$(dirname "$0")/lib_cyborg.sh"

gum style --padding "0 1" --border normal --border-foreground "$C_CYAN" "Gestión de Tareas y Nodos"
# Placeholder: mostrando actividad.log por ahora
tail -f "$SESSION_DIR/actividad.log"
