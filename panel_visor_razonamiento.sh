#!/bin/bash
# CYBorg v2.5 - Panel 4: Visor de Razonamiento IA (MAGERIT)
SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi
source "$(dirname "$0")/lib_cyborg.sh"
gum style --padding "0 1" --border normal --border-foreground "$C_BLUE" "Registro de Razonamiento (MAGERIT)"
while true; do cat "$SESSION_DIR/razonamiento.log"; sleep 5; done
