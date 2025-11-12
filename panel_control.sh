#!/bin/bash
# CYBorg v2.5 - Panel 1: Control Interactivo

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido." >&2
    exit 1
fi

source "$(dirname "$0")/lib_cyborg.sh"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SESSION_DIR/audit_state.conf"

COMMAND_PIPE="$SESSION_DIR/comandos.pipe"
STATUS_FILE="$SESSION_DIR/audit.status"

send_command() {
    local command="$1"
    local message="$2"
    echo "$command" > "$COMMAND_PIPE"
    tmux display-message "$message"
}

show_main_menu() {
    local choice
    choice=$(gum choose --header "Menú Principal" --height 15 \
        "Añadir Hallazgo Manual..." \
        "Abrir Diálogo de Ejemplo (F5)" \
        "Generar Informes" \
        "Salir de CYBorg")

    case "$choice" in
        "Añadir Hallazgo Manual...")
            local finding
            finding=$(gum input --header "Nuevo Hallazgo Manual" --placeholder "Descripción...")
            [ -n "$finding" ] && send_command "ADD_FINDING_MANUAL:$finding" "Hallazgo enviado."
            ;;
        "Abrir Diálogo de Ejemplo (F5)")
            bash "$SCRIPT_DIR/_switch_dialog.sh" open "$SCRIPT_DIR/_dialog_example.sh" "$SESSION_DIR"
            ;;
        "Generar Informes")
             send_command "REPORT_GENERATE" "Solicitud de informes enviada."
            ;;
        "Salir de CYBorg")
             send_command "QUIT" "Comando de salida enviado."
             sleep 0.5
             tmux kill-session -t "$(tmux display-message -p '#S')"
            ;;
        "")
            tmux display-message "Menú cancelado."
            ;;
        *)
            tmux display-message "Acción no implementada."
            ;;
    esac
}

while true; do
    clear
    echo -e "${C_BOLD}${C_CYAN}--- Panel de Control ---${C_RESET}"
    echo "Pulsa [F2] para Menú, [F5] para Diálogo."

    read -s -N 1 -t 1 key
    if [[ $? -eq 0 ]]; then
        if [[ $key == $'\x1b' ]]; then
            read -s -N 2 -t 0.1 sub_key
            key+="$sub_key"
        fi

        case "$key" in
            $'\x1bOQ') # F2
                show_main_menu
                ;;
            $'\x1bOS') # F5
                bash "$SCRIPT_DIR/_switch_dialog.sh" open "$SCRIPT_DIR/_dialog_example.sh" "$SESSION_DIR"
                ;;
        esac
    fi
done
