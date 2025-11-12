#!/bin/bash
# CYBorg v2.5 - Panel 0: Título y Estado

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    echo "Error: Directorio de sesión no proporcionado."
    sleep 5
    exit 1
fi

source "$(dirname "$0")/lib_cyborg.sh"
source "$SESSION_DIR/audit_state.conf"

while true; do
    current_status=$(cat "$SESSION_DIR/audit.status" 2>/dev/null || echo "INICIANDO")

    case "$current_status" in
        "RUNNING")
            status_text="${C_GREEN}● Conectado${C_RESET}"
            ;;
        "STOPPED")
            status_text="${C_YELLOW}● En Pausa${C_RESET}"
            ;;
        *)
            status_text="${C_RED}● Desconectado${C_RESET}"
            ;;
    esac

    config_icon=""
    title="CYBorg - Herramienta de Auditorías de Ciberseguridad"

    header_left=$(gum style --foreground "$C_CYAN" --bold "🛡️ $title")
    header_right=$(gum style "$status_text  $config_icon")

    # Limpiar el panel antes de redibujar
    clear

    # Dibujar línea superior
    gum join --align center --vertical top -- "$header_left" "$header_right"

    # Dibujar el "Panel de Control" fake
    control_panel_title="Panel de Control"
    control_status="No Iniciada"

    left_part=$(gum style --padding "1 2" --bold "$control_panel_title")
    right_part=$(gum style --padding "1 2" --foreground "$C_GRAY" "● $control_status")

    echo # Salto de línea
    gum style --border normal --border-foreground "$C_GRAY" "$(gum join --align left "$left_part" "$right_part")"

    sleep 1
done
