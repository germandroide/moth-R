#!/bin/bash
# CYBorg v2.5 - Panel 3: Visor de Hallazgos de Seguridad
SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi
source "$(dirname "$0")/lib_cyborg.sh"
gum style --padding "0 1" --border normal --border-foreground "$C_CYAN" "Hallazgos de Seguridad (0)"
# Usamos un bucle para evitar el bloqueo de 'tail -f' en el entorno de ejecución.
while true; do cat "$SESSION_DIR/hallazgos.log"; sleep 5; done
