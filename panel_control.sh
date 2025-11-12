#!/bin/bash
# CYBorg v2.5 - Panel de Control Principal e Interactivo

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido." >&2
    exit 1
fi

# Cargar la librería y configuración
source "$(dirname "$0")/lib_cyborg.sh"
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SESSION_DIR/audit_state.conf"

COMMAND_PIPE="$SESSION_DIR/comandos.pipe"
STATUS_FILE="$SESSION_DIR/audit.status"
LOG_FILE="$SESSION_DIR/actividad.log"

# --- FUNCIONES DE UI ---

# Envía un comando al pipe y muestra una notificación en la TUI.
send_command() {
    local command="$1"
    local message="$2"
    echo "$command" > "$COMMAND_PIPE"
    tmux display-message "$message"
}

show_main_menu() {
    local choice
    choice=$(gum choose --header "Menú Principal" --height 20 \
        "Añadir Hallazgo Manual..." \
        "Añadir Anotación de Auditor..." \
        "Parar/Reanudar Tareas Automáticas" \
        "--- ANÁLISIS ---" \
        "Análisis Estratégico Profundo..." \
        "Consultas OSINT (MIE)..." \
        "Análisis Lado Cliente (MALC)..." \
        "Interacción Dinámica (MIAD)..." \
        "Generar Sonda Dinámica (FAD)..." \
        "--- GESTIÓN DE DATOS ---" \
        "Importar Evidencia Externa..." \
        "Generar Informes (Cliente y Técnico)" \
        "Consultar Inteligencia (MAIN)..." \
        "--- SISTEMA ---" \
        "Gestión de Workers (Cluster)..." \
        "Guardar Layout de Paneles..." \
        "Opciones de Configuración..." \
        "Salir de CYBorg" \
    )

    if [[ "$choice" == "---"* ]]; then
        return
    fi

    case "$choice" in
        "Añadir Hallazgo Manual...")
            local finding_desc
            finding_desc=$(gum input --header "Nuevo Hallazgo Manual" --placeholder "Descripción del hallazgo...")
            if [ -n "$finding_desc" ]; then
                send_command "ADD_FINDING_MANUAL:$finding_desc" "Hallazgo manual enviado."
            else
                tmux display-message "Operación cancelada."
            fi
            ;;
        "Añadir Anotación de Auditor...")
            local annotation
            annotation=$(gum write --header "Nueva Anotación" --placeholder "Escribe tus notas...")
            if [ -n "$annotation" ]; then
                send_command "ADD_ANNOTATION:$annotation" "Anotación enviada."
            else
                tmux display-message "Operación cancelada."
            fi
            ;;
        "Parar/Reanudar Tareas Automáticas")
            local is_running=false
            [ -f "$STATUS_FILE" ] && [ "$(cat "$STATUS_FILE")" = "RUNNING" ] && is_running=true
            if ! $is_running; then
                send_command "START" "Comando INICIAR enviado."
                echo "RUNNING" > "$STATUS_FILE"
            else
                send_command "STOP" "Comando PARAR enviado."
                echo "STOPPED" > "$STATUS_FILE"
            fi
            ;;
        "Análisis Estratégico Profundo...")
            local topic
            topic=$(gum input --header "Análisis Estratégico" --placeholder "Tema a investigar (CVE, tecnología, etc.)...")
            if [ -n "$topic" ]; then
                send_command "STRATEGIC_ANALYSIS:$topic" "Solicitud de análisis estratégico enviada."
            else
                tmux display-message "Operación cancelada."
            fi
            ;;
        "Importar Evidencia Externa...")
            local file_to_import
            file_to_import=$(bash "$SCRIPT_DIR/_dialog_file_explorer.sh" "$HOME/Documents")
            if [ -n "$file_to_import" ]; then
                send_command "IMPORT_EVIDENCE:$file_to_import" "Solicitud de importación para '$file_to_import' enviada."
            else
                tmux display-message "Importación cancelada."
            fi
            ;;
        "Generar Informes (Cliente y Técnico)")
             send_command "REPORT_GENERATE" "Solicitud de generación de informes enviada."
            ;;
        "Consultar Inteligencia (MAIN)...")
            local query
            query=$(gum input --header "Consultar Base de Inteligencia (MAIN)" --placeholder "Pregunta en lenguaje natural...")
            if [ -n "$query" ]; then
                send_command "MAIN_QUERY:$query" "Consulta a MAIN enviada."
            else
                tmux display-message "Operación cancelada."
            fi
            ;;
        "Opciones de Configuración...")
            bash "$SCRIPT_DIR/_dialog_config_ia.sh" "$SESSION_DIR"
            # No se necesita enviar comando, el diálogo modifica el estado directamente.
            ;;
        "Salir de CYBorg")
             send_command "QUIT" "Comando de salida enviado. Hasta pronto."
             sleep 0.5
             tmux kill-session -t "$(tmux display-message -p '#S')"
            ;;
        "")
            tmux display-message "Menú cancelado."
            ;;
        *)
            tmux display-message "Acción '$choice' no implementada todavía."
            ;;
    esac
}

while true; do
    clear
    echo -e "${C_BOLD}${C_CYAN}--- Panel de Control ---${C_RESET}"
    echo ""
    echo " CYBorg TUI está activa."

    local is_running=false
    [ -f "$STATUS_FILE" ] && [ "$(cat "$STATUS_FILE")" = "RUNNING" ] && is_running=true
    if $is_running; then
        echo -e " Estado: ${C_GREEN}EN CURSO${C_RESET}"
    else
        echo -e " Estado: ${C_YELLOW}DETENIDA${C_RESET}"
    fi

    echo ""
    echo -e " ${C_YELLOW}Pulsa [F2] para abrir el Menú Principal.${C_RESET}"
    echo -e " ${C_YELLOW}Pulsa [F3] para cambiar de vista.${C_RESET}"
    echo -e " ${C_YELLOW}Pulsa [Q] para salir.${C_RESET}"
    echo ""

    read -s -N 1 -t 1 key
    if [[ $? -eq 0 ]]; then
        if [[ $key == $'\x1b' ]]; then
            read -s -N 2 -t 0.1 sub_key
            key+="$sub_key"
        fi

        case "$key" in
            $'\x1bOQ')
                show_main_menu
                ;;
            $'\x1bOR')
                local view_choice
                view_choice=$(gum choose "Mando y Control" "Análisis de Hallazgos" "Gestión del Clúster")

                case "$view_choice" in
                    "Mando y Control")
                        bash "$SCRIPT_DIR/_switch_view.sh" "default" "$SESSION_DIR"
                        ;;
                    "Análisis de Hallazgos")
                        bash "$SCRIPT_DIR/_switch_view.sh" "analisis_hallazgos" "$SESSION_DIR"
                        ;;
                    "Gestión del Clúster")
                        bash "$SCRIPT_DIR/_switch_view.sh" "gestion_cluster" "$SESSION_DIR"
                        ;;
                    "")
                        tmux display-message "Cambio de vista cancelado."
                        ;;
                esac
                ;;
            q|Q)
                send_command "QUIT" "Comando de salida enviado. Hasta pronto."
                sleep 0.5
                tmux kill-session -t "$(tmux display-message -p '#S')"
                break
                ;;
        esac
    fi
done
