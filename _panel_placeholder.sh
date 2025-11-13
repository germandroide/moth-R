#!/bin/bash
# CYBorg v2.5 - Panel Placeholder

PANEL_NUMBER=$1
PANEL_NAME=$2

# Cargar la librería para los colores
source "$(dirname "$0")/lib_cyborg.sh"

# Bucle infinito para mantener el panel vivo.
while true; do
    clear
    echo -e "${C_BOLD}${C_CYAN}Panel $PANEL_NUMBER: $PANEL_NAME${C_RESET}"
    echo ""
    echo "Este es un panel de marcador de posición."
    echo "Será reemplazado por el script final."
    sleep 60
done
