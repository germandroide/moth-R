#!/bin/bash
# CYBorg v2.5 - Lanzador Principal de la TUI

# --- VARIABLES GLOBALES Y CONSTANTES ---
SCRIPT_DIR=$(dirname "$(realpath "$0")")
AUDITS_BASE_DIR="$HOME/Documents/Auditorias_CYBorg"
DB_FILE="$SCRIPT_DIR/cyborg_intelligence.db"

# Cargar la librería para colores e iconos
source "$SCRIPT_DIR/lib_cyborg.sh"

# --- FUNCIONES ---

# Muestra el uso correcto del script y sale.
show_usage() {
    echo -e "${C_BOLD}Uso:${C_RESET} $0 <nombre_auditor> <objetivo_ip> [--testing]"
    echo -e "\n  nombre_auditor: Tu nombre o identificador."
    echo "  objetivo_ip:    La dirección IP o dominio principal bajo auditoría."
    echo "  --testing:      Activa el modo de pruebas (no crea directorios persistentes)."
    exit 1
}

# Función para verificar que las dependencias necesarias están instaladas.
check_dependencies() {
    local missing_deps=0
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
    local session_dir=$1
    local testing_flag=$2
    local session_name="cyborg_session_$$"

    echo "Lanzando entorno TUI en tmux..."

    # Usar 'exec' para reemplazar el proceso actual del script con tmux.
    # Se pasa el directorio de sesión al script de secuencia de inicio.
    exec tmux new-session -s "$session_name" "bash $SCRIPT_DIR/_startup_sequence.sh '$session_dir' 'mando_y_control' '$testing_flag'"
}

# --- FLUJO PRINCIPAL ---

# Parsear argumentos de línea de comandos
if [ "$#" -lt 2 ]; then
    show_usage
fi
AUDITOR_NAME=$1
TARGET_IP=$2
shift 2
TESTING_MODE=false
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --testing)
        TESTING_MODE=true
        shift
        ;;
        *)
        show_usage
        ;;
    esac
done

clear
echo -e "${C_BOLD}${C_CYAN}Iniciando CYBorg v2.5...${C_RESET}"
echo "-----------------------------------"

check_dependencies

# Crear directorio de sesión
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_NAME="${TARGET_IP}_${TIMESTAMP}"
SESSION_DIR="$AUDITS_BASE_DIR/$SESSION_NAME"

if ! $TESTING_MODE; then
    mkdir -p "$SESSION_DIR"
    # Crear archivos de comunicación y estado
    mkfifo "$SESSION_DIR/comandos.pipe"
    touch "$SESSION_DIR/actividad.log"
    touch "$SESSION_DIR/hallazgos.log"
    touch "$SESSION_DIR/razonamiento.log"
    echo "STOPPED" > "$SESSION_DIR/audit.status"
    # Crear el fichero de estado con los datos de la auditoría
    cat << EOF > "$SESSION_DIR/audit_state.conf"
AUDITOR_NAME="$AUDITOR_NAME"
TARGET_IP="$TARGET_IP"
SESSION_NAME="$SESSION_NAME"
AI_MODE="HYBRID"
STRATEGIC_AI_PROVIDER="GEMINI"
EOF
else
    # En modo testing, usamos un directorio temporal
    SESSION_DIR=$(mktemp -d)
    # Crear igualmente los ficheros para que la TUI no falle
    mkfifo "$SESSION_DIR/comandos.pipe"
    touch "$SESSION_DIR/actividad.log"
    touch "$SESSION_DIR/hallazgos.log"
    touch "$SESSION_DIR/razonamiento.log"
    echo "STOPPED" > "$SESSION_DIR/audit.status"
    cat << EOF > "$SESSION_DIR/audit_state.conf"
AUDITOR_NAME="Test"
TARGET_IP="127.0.0.1"
SESSION_NAME="testing_session"
AI_MODE="HYBRID"
STRATEGIC_AI_PROVIDER="GEMINI"
EOF
fi

echo "Directorio de sesión preparado en: $SESSION_DIR"

# Lanzar la TUI
launch_tmux_session "$SESSION_DIR" "$TESTING_MODE"

# Este código solo se ejecuta si tmux falla.
echo "Error al lanzar tmux. Saliendo."
# Limpieza en caso de fallo
if [ -d "$SESSION_DIR" ] && $TESTING_MODE; then
    rm -rf "$SESSION_DIR"
fi
exit 1
