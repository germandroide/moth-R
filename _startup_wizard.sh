#!/bin/bash
# CYBorg v2.5 - Asistente de Configuración Interactivo (TUI)

TESTING_MODE=$1
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source "$SCRIPT_DIR/lib_cyborg.sh"

clear
gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 \
"Bienvenido a ${C_BOLD}${C_CYAN}CYBorg v2.5${C_RESET}" \
"Este asistente te guiará para configurar una nueva sesión de auditoría."

echo ""
gum style --bold "--- FASE 1: VERIFICACIÓN DE ENTORNO ---"
sleep 1

# Verificar IA Estratégica
echo "Verificando IA Estratégica (Gemini)..."
if ! gemini-cli -m "gemini-2.5-flash" -p "test" &> /dev/null; then
    gum style --foreground "red" "Error: 'gemini-cli' no parece estar configurado. Ejecuta 'gemini pro login' en otro terminal y vuelve a iniciar."
    sleep 10
    exit 1
fi
echo -e " ${C_GREEN}${ICON_OK} Conexión con Gemini verificada.${C_RESET}"
sleep 1

# Verificar IA Táctica
echo "Verificando IA Táctica (Ollama)..."
if ! curl -s -f http://localhost:11434 > /dev/null; then
    gum style --foreground "red" "Error: El servicio de Ollama no está disponible. Ejecuta 'ollama serve' en otro terminal y vuelve a iniciar."
    sleep 10
    exit 1
fi
echo -e " ${C_GREEN}${ICON_OK} Servicio Ollama disponible.${C_RESET}"
sleep 1

# --- FASE 2: RECOPILACIÓN DE RECURSOS ---
echo ""
gum style --bold "--- FASE 2: RECURSOS DEL SISTEMA ---"
_get_system_resources
sleep 2

# --- FASE 3: CONFIGURACIÓN DE LA AUDITORÍA ---
echo ""
gum style --bold "--- FASE 3: CONFIGURACIÓN DE AUDITORÍA ---"

MODE=$(gum choose "Standalone" "Orchestrator" "Worker" --header "Selecciona el modo de operación:")

if [ "$MODE" = "Worker" ]; then
    gum style --border normal --margin "1" "Modo Worker Activado. Esta ventana se puede cerrar. El worker se ejecutará en segundo plano."
    # Aquí iría la lógica para demonizar el proceso worker.
    # Por ahora, simplemente salimos del wizard.
    exit 0
fi

if [ "$TESTING_MODE" = "true" ]; then
    AUDITOR_NAME="Germán"
    AUDITOR_COMPANY="personal"
    ADDITIONAL_TECHS="n/a"
    TARGET_IP=$(gum input --placeholder "IP Objetivo de la Auditoría" --value "127.0.0.1")
else
    TARGET_IP=$(gum input --placeholder "IP Objetivo de la Auditoría")
    AUDITOR_NAME=$(gum input --placeholder "Nombre del Auditor Principal")
    AUDITOR_COMPANY=$(gum input --placeholder "Nombre de la Empresa Auditora")
    ADDITIONAL_TECHS=$(gum input --placeholder "Otros Técnicos (separados por comas)")
fi

if [ -z "$TARGET_IP" ]; then
    gum style --foreground "red" "Error: La IP objetivo es obligatoria."
    exit 1
fi

# --- FASE 4: CREACIÓN DE LA SESIÓN ---
gum spin --spinner dot --title "Creando estructura de la sesión de auditoría..." -- \
SESSION_DIR=$(_create_audit_session "$TARGET_IP" "$AUDITOR_NAME" "$AUDITOR_COMPANY" "$ADDITIONAL_TECHS" "$MODE" "$TESTING_MODE")

if [ -z "$SESSION_DIR" ]; then
    gum style --foreground "red" "Error: No se pudo crear la sesión de auditoría."
    exit 1
fi

gum style --foreground "green" "Sesión creada en: $SESSION_DIR"
sleep 2

# --- FASE 5: TRANSICIÓN AL LAYOUT PRINCIPAL ---
# Este es el paso final y más importante.
# Reconfiguramos la TUI al estado operativo.

# 1. Renombrar la ventana del ejecutor y lanzarlo con la sesión correcta.
tmux rename-window -t "Executor-Idle" "Executor"
tmux respawn-pane -t "Executor" "bash $SCRIPT_DIR/panel_ejecutor.sh '$SESSION_DIR'"

# 2. Cargar el layout por defecto. Esto matará este script y recargará todos los paneles.
# Es una forma limpia de hacer la transición.
bash "$SCRIPT_DIR/layouts/default.sh" "$SESSION_DIR"

# El script no debería llegar aquí, pero por si acaso.
exit 0