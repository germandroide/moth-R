#!/bin/bash
# CYBorg v2.5 - Panel de Cabecera (Header)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then exit 1; fi

source "$(dirname "$0")/lib_cyborg.sh"
CONFIG_FILE="$SESSION_DIR/audit_state.conf"
STATUS_FILE="$SESSION_DIR/audit.status"

# Bucle infinito para refrescar la cabecera periódicamente
while true; do
    # Cargar los datos más recientes
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        # Valores por defecto mientras se configura la sesión
        TARGET_IP="N/A"
        MODE="N/A"
    fi

    status_text="DETENIDA"
    status_color="$C_YELLOW"
    if [ -f "$STATUS_FILE" ] && [ "$(cat "$STATUS_FILE")" = "RUNNING" ]; then
        status_text="EN CURSO"
        status_color="$C_GREEN"
    fi

    # Obtener el ancho del terminal para alinear el texto
    width=$(tmux display -p '#{pane_width}')

    # Construir las partes de la cabecera
    left_part="${C_BOLD}${C_CYAN}CYBorg v2.5${C_RESET} | ${ICON_TARGET} ${TARGET_IP}"
    center_part="${ICON_WORKER} Modo: ${C_BOLD}${MODE}${C_RESET}"
    right_part="Estado: ${status_color}${C_BOLD}${status_text}${C_RESET}"

    # Limpiar cadenas de control para el cálculo de la longitud
    clean_string() {
        echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g'
    }

    left_len=$(clean_string "$left_part" | wc -c)
    center_len=$(clean_string "$center_part" | wc -c)
    right_len=$(clean_string "$right_part" | wc -c)

    # Cálculo del espaciado
    total_len=$((left_len + center_len + right_len))

    # Asegurarse de que el espacio no sea negativo si la ventana es muy pequeña
    space_needed=$((width - left_len - center_len - right_len))
    [ $space_needed -lt 0 ] && space_needed=0

    space_after_left=$(( (width - center_len) / 2 - left_len ))
    [ $space_after_left -lt 0 ] && space_after_left=0

    space_after_center=$(( width - left_len - space_after_left - center_len - right_len ))
    [ $space_after_center -lt 0 ] && space_after_center=0

    # Limpiar la línea e imprimir
    printf "\r%*s" "$width" ""
    printf "\r%b%*s%b%*s%b" "$left_part" "$space_after_left" "" "$center_part" "$space_after_center" "" "$right_part"

    sleep 1
done