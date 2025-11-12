#!/bin/bash
# CYBorg v2.5 - Panel 5: Visor de Registro de Actividad
SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi
source "$(dirname "$0")/lib_cyborg.sh"
gum style --padding "0 1" --border normal --border-foreground "$C_GRAY" "Registro de Actividad"
while true; do cat "$SESSION_DIR/actividad.log"; sleep 5; done
