#!/bin/bash
# CYBorg v2.5 - Panel Ejecutor (Orquestador de Tareas)

# --- CONFIGURACIÓN Y VALIDACIÓN INICIAL ---
SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error Crítico: El Panel Ejecutor requiere un directorio de sesión válido." >&2
    exit 1
fi

# Cargar la librería y el estado de la auditoría
source "$(dirname "$0")/lib_cyborg.sh"
source "$SESSION_DIR/audit_state.conf"

# --- VARIABLES DE ESTADO ---
LOG_FILE="$SESSION_DIR/actividad.log"
COMMAND_PIPE="$SESSION_DIR/comandos.pipe"
STATUS_FILE="$SESSION_DIR/audit.status"
AUDIT_PID=0 # Almacenará el PID del proceso de auditoría en segundo plano

# --- MANEJO DE SEÑALES Y LIMPIEZA ---
# Función para detener la auditoría de forma segura
cleanup() {
    log_activity "$LOG_FILE" "EJECUTOR" "Señal de terminación recibida. Limpiando..."
    if [ "$AUDIT_PID" -ne 0 ] && ps -p $AUDIT_PID > /dev/null; then
        # Matar el grupo de procesos para detener también a los hijos (nmap, etc.)
        kill -SIGTERM -- "-$AUDIT_PID" 2>/dev/null
    fi
    echo "STOPPED" > "$STATUS_FILE"
    log_activity "$LOG_FILE" "EJECUTOR" "Proceso de limpieza finalizado. Saliendo."
    exit 0
}
trap cleanup SIGINT SIGTERM # Atrapar Ctrl+C y señales de terminación

# --- FUNCIONES PRINCIPALES DE ORQUESTACIÓN ---

# Inicia el workflow de auditoría principal en segundo plano
start_audit() {
    if [ "$AUDIT_PID" -ne 0 ] && ps -p $AUDIT_PID > /dev/null; then
        log_activity "$LOG_FILE" "EJECUTOR" "La auditoría ya está en curso. No se tomará ninguna acción."
        return
    fi

    log_activity "$LOG_FILE" "EJECUTOR" "Iniciando workflow de auditoría..."
    echo "RUNNING" > "$STATUS_FILE"

    # Lanzamos el workflow en un nuevo grupo de procesos para poder matarlo de forma controlada
    setsid bash -c "run_web_audit_workflow '$SESSION_DIR' '$TARGET_IP' '$LOG_FILE' '$COMMAND_PIPE'" &
    AUDIT_PID=$!
    log_activity "$LOG_FILE" "EJECUTOR" "Workflow iniciado en segundo plano con PID: $AUDIT_PID."
}

# Detiene el workflow de auditoría en curso
stop_audit() {
    log_activity "$LOG_FILE" "EJECUTOR" "Solicitud para detener la auditoría..."
    if [ "$AUDIT_PID" -ne 0 ] && ps -p $AUDIT_PID > /dev/null; then
        log_activity "$LOG_FILE" "EJECUTOR" "Enviando señal de terminación al grupo de procesos $AUDIT_PID..."
        kill -SIGTERM -- "-$AUDIT_PID" 2>/dev/null
        AUDIT_PID=0
    else
        log_activity "$LOG_FILE" "EJECUTOR" "No hay ninguna auditoría en curso para detener."
    fi
    echo "STOPPED" > "$STATUS_FILE"
}

# --- BUCLE PRINCIPAL DEL CONSUMIDOR ---
log_activity "$LOG_FILE" "EJECUTOR" "Panel Ejecutor iniciado y escuchando en la cola de comandos."

while true; do
    # 'read' se bloqueará aquí hasta que algo se escriba en el pipe
    if read -r command < "$COMMAND_PIPE"; then
        log_activity "$LOG_FILE" "EJECUTOR" "Comando recibido de la cola: '$command'"

        case "$command" in
            START)
                start_audit
                ;;
            STOP)
                stop_audit
                ;;
            REPORT_GENERATE)
                log_activity "$LOG_FILE" "EJECUTOR" "Iniciando generación de informe en segundo plano..."
                # Ejecutar en segundo plano para no bloquear al ejecutor
                "$(dirname "$0")/generate_report.sh" "$SESSION_DIR" &
                ;;
            QUIT)
                log_activity "$LOG_FILE" "EJECUTOR" "Comando de salida recibido. Terminando..."
                cleanup
                ;;
            *)
                # Cualquier otro comando se asume que es una tarea discreta (probablemente de la IA)
                if [ -n "$command" ]; then
                     log_activity "$LOG_FILE" "EJECUTOR" "Ejecutando tarea discreta: $command"
                     # La tarea se ejecuta en segundo plano para que el orquestador siga disponible
                     # El modo es ORCHESTRATOR/STANDALONE, así que el worker es "local" por ahora
                     _execute_task_with_rag "$SESSION_DIR" "$LOG_FILE" "$command" "$TARGET_IP" "local" &
                fi
                ;;
        esac
    fi
    # Pequeña pausa para evitar un bucle descontrolado si el pipe se rompe
    sleep 0.1
done