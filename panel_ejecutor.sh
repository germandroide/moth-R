#!/bin/bash
# CYBorg v2.5 - Panel Ejecutor de Tareas (Consumidor/Orquestador)

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    # No podemos loguear a un archivo si no hay sesión.
    # Enviamos el error a stderr.
    echo "Error Crítico: El panel ejecutor requiere un directorio de sesión válido." >&2
    exit 1
fi

# Cargar la librería de lógica de negocio y la configuración de la sesión
source "$(dirname "$0")/lib_cyborg.sh"
source "$SESSION_DIR/audit_state.conf"

COMMAND_PIPE="$SESSION_DIR/comandos.pipe"
LOG_FILE="$SESSION_DIR/actividad.log"
STATUS_FILE="$SESSION_DIR/audit.status"

# --- BUCLE PRINCIPAL DEL CONSUMIDOR ---

log_activity "$LOG_FILE" "SYSTEM" "Panel ejecutor iniciado. Escuchando comandos..."

# Bucle infinito que lee comandos del pipe (cola de tareas).
# El `read` bloquea la ejecución hasta que llega un nuevo comando.
while read -r command; do

    # Extraer el comando base y los argumentos (si los hay).
    # Formato esperado: COMANDO:argumento1:argumento2...
    IFS=':' read -r cmd_base arg1 <<< "$command"

    # Ignorar líneas vacías
    if [ -z "$cmd_base" ]; then
        continue
    fi

    log_activity "$LOG_FILE" "EXECUTOR" "Comando recibido: $cmd_base"

    # El 'case' es el router principal que mapea un comando a una función de la librería.
    case "$cmd_base" in
        "START")
            echo "RUNNING" > "$STATUS_FILE"
            log_activity "$LOG_FILE" "SYSTEM" "Auditoría iniciada. Lanzando workflow inicial..."
            # En una implementación real, aquí se llamaría al workflow por defecto.
            # Por ahora, simulamos una tarea.
            echo "TASK:NMAP_SCAN:localhost" > "$COMMAND_PIPE"
            ;;
        "STOP")
            echo "STOPPED" > "$STATUS_FILE"
            log_activity "$LOG_FILE" "SYSTEM" "Auditoría en pausa. Se completará la tarea actual."
            # Aquí se podría implementar lógica para no aceptar más tareas.
            ;;
        "QUIT")
            log_activity "$LOG_FILE" "SYSTEM" "Comando de apagado recibido. Terminando..."
            echo "STOPPED" > "$STATUS_FILE"
            # No necesitamos hacer 'exit', el `read` fallará cuando el pipe se cierre.
            break
            ;;
        "REPORT_GENERATE")
            log_activity "$LOG_FILE" "EXECUTOR" "Iniciando generación de informes..."
            # Llamada a la función de la librería que hace el trabajo.
            generate_reports "$SESSION_DIR"
            ;;
        "ADD_FINDING_MANUAL")
            log_activity "$LOG_FILE" "EXECUTOR" "Añadiendo hallazgo manual: '$arg1'"
            # Aquí iría la llamada a `_persist_finding_to_db`
            ;;
        "ADD_ANNOTATION")
            log_activity "$LOG_FILE" "EXECUTOR" "Añadiendo anotación: '$arg1'"
            # Aquí iría la lógica para guardar la anotación.
            ;;
        "STRATEGIC_ANALYSIS")
            log_activity "$LOG_FILE" "EXECUTOR" "Iniciando análisis estratégico para: '$arg1'"
            # Aquí se llamaría a `run_cyborg_strategic_analysis`
            ;;
        "MAIN_QUERY")
            log_activity "$LOG_FILE" "EXECUTOR" "Ejecutando consulta en MAIN: '$arg1'"
            # Aquí se llamaría a `run_main_intelligence_query`
            ;;
        "IMPORT_EVIDENCE")
            log_activity "$LOG_FILE" "EXECUTOR" "Solicitud para importar evidencia: '$arg1'"
            # Aquí iría la lógica para procesar el archivo importado.
            ;;
        "TASK")
            local task_name=$arg1
            local task_target=${command#*:$task_name:} # El resto de la cadena
            log_activity "$LOG_FILE" "TASK_RUNNER" "Ejecutando tarea '$task_name' sobre '$task_target'"
            # Placeholder para la ejecución de tareas reales.
            # En el futuro, aquí se llamaría a `_execute_task_with_rag`
            sleep 2 # Simular trabajo
            log_activity "$LOG_FILE" "TASK_RUNNER" "Tarea '$task_name' completada."
            ;;
        *)
            log_activity "$LOG_FILE" "ERROR" "Comando desconocido recibido: '$cmd_base'"
            ;;
    esac
done

log_activity "$LOG_FILE" "SYSTEM" "Panel ejecutor terminado."
