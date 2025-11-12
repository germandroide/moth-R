#!/bin/bash
# CYBorg v2.5 - Lanzador Principal de la TUI

# --- VARIABLES GLOBALES Y CONSTANTES ---
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# Nota: SESSION_DIR y AUDITS_BASE_DIR ahora se manejan dentro del wizard.
DB_FILE="$SCRIPT_DIR/cyborg_intelligence.db"

# Cargar la librería para colores e iconos
source "$SCRIPT_DIR/lib_cyborg.sh"

# --- FUNCIONES ---

# Muestra el uso correcto del script y sale.
show_usage() {
    echo -e "${C_BOLD}Uso:${C_RESET} $0 [--testing]"
    echo -e "\nEl lanzador inicia directamente la TUI. La configuración se realiza dentro."
    echo -e "  --testing: Activa el modo de pruebas dentro del asistente de la TUI."
    exit 1
}

# Función para verificar que las dependencias necesarias están instaladas.
check_dependencies() {
    local missing_deps=0
    # Quitamos whiptail, ya que usaremos gum para todo.
    local deps=("tmux" "nmap" "xmllint" "xsltproc" "curl" "jq" "gemini-cli" "node" "npm" "sqlite3" "ssh" "scp" "bc" "gum" "lspci" "ip")
    echo "Verificando dependencias de software..."
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "  ${C_RED}${ICON_ERROR} Falta dependencia: $cmd${C_RESET}"
            missing_deps=1
        fi
    done

    if [ "$missing_deps" -eq 1 ]; then
        echo -e "\n${C_BOLD}${C_RED}Error: Faltan dependencias críticas. Por favor, instálalas antes de continuar.${C_RESET}"
        exit 1
    fi
    echo -e "${C_GREEN}Dependencias verificadas.${C_RESET}\n"
}

# Lanza la sesión de tmux de forma visible para el usuario.
launch_tmux_session() {
    local session_name="cyborg_session_$$"
    local testing_flag=$1

    echo "Lanzando entorno TUI en tmux..."

    # Usar 'exec' para reemplazar el proceso actual del script con tmux.
    exec tmux new-session -s "$session_name" "bash $SCRIPT_DIR/_startup_sequence.sh '' 'startup_wizard' '$testing_flag'"
}

# --- FLUJO PRINCIPAL ---

# Parsear argumentos de línea de comandos
TESTING_MODE=false
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --testing)
        TESTING_MODE=true
        shift # past argument
        ;;
        *)    # unknown option
        show_usage
        ;;
    esac
done

clear
echo -e "${C_BOLD}${C_CYAN}Iniciando CYBorg v2.5...${C_RESET}"
echo "-----------------------------------"

check_dependencies

# Ya no se pregunta nada aquí. Se lanza directamente la TUI.
launch_tmux_session "$TESTING_MODE"

echo "Sesión de tmux terminada. ¡Hasta la próxima!"
exit 0