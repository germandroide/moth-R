#!/bin/bash
# CYBorg v2.5 - Panel de Cabecera (Header)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ]; then
    # Este panel no puede funcionar sin un directorio de sesión.
    # Mostramos un mensaje de error y salimos.
    echo "Error: Directorio de sesión no proporcionado a la cabecera."
    sleep 5
    exit 1
fi

# Cargar la librería para colores, iconos y funciones comunes.
source "$(dirname "$0")/lib_cyborg.sh"

# Cargar el estado actual de la auditoría para obtener los datos a mostrar.
source "$SESSION_DIR/audit_state.conf"

# Bucle principal para mantener el panel vivo y refrescar la información.
while true; do
    # Leemos el estado actual (RUNNING, STOPPED, etc.)
    current_status=$(cat "$SESSION_DIR/audit.status" 2>/dev/null || echo "INICIANDO")

    # --- LÓGICA DE VISUALIZACIÓN ---

    # 1. Título principal de la aplicación.
    title="CYBorg - Herramienta de Auditorías de Ciberseguridad"

    # 2. Estado de la conexión/auditoría.
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

    # 3. Icono de configuración (u otras acciones).
    config_icon=""

    # --- RENDERIZADO CON GUM ---

    # Usamos 'gum join' para crear una línea de texto horizontal con tres secciones:
    # izquierda, centro y derecha.

    header_left=$(gum style --foreground "$C_CYAN" --bold "🛡️ $title")
    header_right=$(gum style "$status_text  $config_icon")

    # 'gum join' necesita saber el ancho total para alinear correctamente.
    # Usamos 'tput cols' para obtener el ancho actual del terminal.
    gum join --align center --vertical top -- "$header_left" "$header_right"

    # Línea separadora inferior para un mejor acabado visual.
    gum style --border normal --border-foreground "$C_GRAY" --width "$(tput cols)" ""

    # Esperamos un segundo antes de volver a dibujar.
    # Esto reduce el consumo de CPU y evita parpadeos.
    sleep 1
done
