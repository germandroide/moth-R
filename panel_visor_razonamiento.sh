#!/bin/bash
# CYBorg v2.5 - Panel Visor de Razonamiento (IA)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido."
    exit 1
fi

REASONING_FILE="$SESSION_DIR/razonamiento.log"
source "$(dirname "$0")/lib_cyborg.sh"

# Asegurarse de que el archivo existe
touch "$REASONING_FILE"

# Bucle para refrescar y formatear la salida
while true; do
    clear
    echo -e "${C_BOLD}${C_CYAN}--- Visor de Razonamiento (IA) ---${C_RESET}"
    echo "------------------------------------"

    if [ -f "$REASONING_FILE" ]; then
        # Mostrar las últimas 20 líneas del log de razonamiento
        tail -n 20 "$REASONING_FILE" | while IFS= read -r line; do
            # Aplicar colores basados en el tipo de IA
            if [[ "$line" == *"[${ICON_BRAIN} IA Táctica]"* ]]; then
                # Colorear en magenta lo que viene después del tag
                echo -e "${C_BOLD}${C_MAGENTA}[${ICON_BRAIN} IA Táctica]${C_RESET} ${C_MAGENTA}${line#*]* }${C_RESET}"
            elif [[ "$line" == *"[${ICON_STRATEGY} IA Estratégica]"* ]]; then
                # Colorear en azul lo que viene después del tag
                echo -e "${C_BOLD}${C_BLUE}[${ICON_STRATEGY} IA Estratégica]${C_RESET} ${C_BLUE}${line#*]* }${C_RESET}"
            else
                # Imprimir la línea sin formato si no coincide
                echo "$line"
            fi
        done
    fi

    sleep 1
done