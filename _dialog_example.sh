#!/bin/bash
# CYBorg v2.5 - Diálogo de Ejemplo para Conmutación

SESSION_DIR=$1
SCRIPT_DIR=$(dirname "$(realpath "$0")")

clear
gum style --padding "2 5" --border double --border-foreground "212" \
"Este es un Panel de Diálogo Temporal" \
"Ocupa el espacio de los paneles 2 y 3." \
"" \
"Presiona cualquier tecla para volver a la vista anterior."

# Esperar a que el usuario presione una tecla
read -n 1

# Llamar al script de conmutación en modo 'close' para restaurar
bash "$SCRIPT_DIR/_switch_dialog.sh" close "" "$SESSION_DIR"
