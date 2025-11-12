#!/bin/bash
# CYBorg v2.5 - Panel Visor de Actividad (Dashboard de Tareas)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido."
    exit 1
fi

LOG_FILE="$SESSION_DIR/actividad.log"
source "$(dirname "$0")/lib_cyborg.sh"

# Asegurarse de que el archivo existe
touch "$LOG_FILE"

# Bucle principal para refrescar el panel
while true; do
    clear
    echo -e "${C_BOLD}${C_CYAN}--- Visor de Actividad y Tareas ---${C_RESET}"
    echo "------------------------------------"

    # Procesar el archivo de log para mostrar un estado bonito
    if [ -f "$LOG_FILE" ]; then
        # Usamos tac para leer el archivo en orden inverso y 'head' para limitar las últimas N líneas
        tac "$LOG_FILE" | head -n 20 | while IFS= read -r line; do
            # Extraer el componente y el mensaje
            timestamp=$(echo "$line" | cut -d' ' -f1,2)
            component=$(echo "$line" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')
            message=$(echo "$line" | sed 's/.*] - //')

            # Formatear la salida con colores e iconos según el mensaje
            formatted_line=""
            case "$message" in
                *Iniciando*workflow*)
                    formatted_line="${C_YELLOW}[»]${C_RESET} ${message}"
                    ;;
                *completado*)
                    formatted_line="${C_GREEN}[]${C_RESET} ${message}"
                    ;;
                *Analizando*resultados*)
                    formatted_line="${C_CYAN}[+]${C_RESET} ${message}"
                    ;;
                *Comando*generado*)
                    formatted_line="${C_GRAY}[${ICON_AI}] ${C_RESET}${C_GRAY}${message}${C_RESET}"
                    ;;
                *solicitó*INICIAR*)
                    formatted_line="${C_GREEN}[▶]${C_RESET} Auditoría iniciada por el usuario."
                    ;;
                *solicitó*PARAR*)
                     formatted_line="${C_RED}[■]${C_RESET} Auditoría detenida por el usuario."
                    ;;
                *)
                    formatted_line="${C_WHITE}[·]${C_RESET} ${message}"
                    ;;
            esac
            echo -e "$formatted_line"
        done | tac # Volver a poner las líneas en orden cronológico
    fi

    sleep 1
done