#!/bin/bash
# CYBorg v2.5 - Librería de funciones compartidas

# --- COLORES Y ESTILOS ---
C_RESET='\e[0m'
C_BOLD='\e[1m'
C_RED='\e[31m'
C_GREEN='\e[32m'
C_YELLOW='\e[33m'
C_BLUE='\e[34m'
C_MAGENTA='\e[35m'
C_CYAN='\e[36m'
C_WHITE='\e[37m'
C_GRAY='\e[90m'
C_BG_BLUE='\e[44m'
C_BG_GRAY='\e[100m'
C_BLACK='\e[30m'

# --- ICONOS ---
ICON_INFO=""
ICON_WARN=""
ICON_ERROR=""
ICON_CMD=""
ICON_STATUS=""
ICON_OK=""
ICON_TARGET="🎯"
ICON_SESSION=""
ICON_REPORT=""
ICON_FINDING=""
ICON_EXIT=""
ICON_AI=""
ICON_BRAIN="🧠"
ICON_SHIELD="🛡️"
ICON_STRATEGY="♟️"
ICON_PROBE="📡"
ICON_CUSTOM=""
ICON_OSINT=""
ICON_CLIENT_SIDE=""
ICON_DYNAMIC="⚙️"
ICON_CONFIG=""
ICON_WORKER=""

# --- LOGGING CENTRALIZADO ---
log_activity() {
    local log_file="$1"
    local component="$2"
    local message="$3"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [${component}] - ${message}" >> "$log_file"
}

log_reasoning() {
    local session_dir="$1"
    local message="$2"
    echo -e "${C_BOLD}${C_MAGENTA}[${ICON_BRAIN} IA Táctica]${C_RESET} ${message}" > "$session_dir/razonamiento.log"
}

log_strategic_reasoning() {
    local session_dir="$1"
    local message="$2"
    echo -e "${C_BOLD}${C_BLUE}[${ICON_STRATEGY} IA Estratégica]${C_RESET} ${message}" > "$session_dir/razonamiento.log"
}

log_finding() {
    local session_dir="$1"
    local severity="$2"
    local message="$3"
    local finding_to_log="[${severity}] ${message}"
    echo "$finding_to_log" >> "$session_dir/hallazgos.log"
}

log_cluster_activity() {
    local message="$1"
    # Esta función asume que CLUSTER_LOG_FILE está definido en el script que la llama.
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$CLUSTER_LOG_FILE"
}

# --- RENDERIZADO DE UI ---
render_control_panel() {
    local audit_status=$1
    source "$SESSION_DIR/audit_state.conf"

    clear
    echo -e "${C_BOLD}${C_CYAN}--- Panel de Comandos ---${C_RESET}"
    echo ""

    if [ "$audit_status" = "true" ]; then
        echo -e " ${ICON_CMD} [${C_RED}s${C_RESET}] Parar Tareas"
        echo ""
        echo -e "--- ${C_BOLD}Acciones de Auditoría${C_RESET} ---"
        echo -e " ${ICON_FINDING} [${C_GREEN}f${C_RESET}] Añadir Hallazgo Manual..."
        echo -e " ${ICON_AI} [${C_GREEN}a${C_RESET}] Análisis Estratégico..."
        echo -e " ${ICON_REPORT} [${C_GREEN}g${C_RESET}] Generar Informes"

        if [ "$MODE" = "ORCHESTRATOR" ]; then
            echo -e " ${ICON_WORKER} [${C_CYAN}w${C_RESET}] Gestión de Workers..."
        fi

    else
        echo -e " ${ICON_CMD} [${C_GREEN}s${C_RESET}] Iniciar Tareas"
        echo ""
        echo -e " ${C_GRAY}(Otras acciones se habilitarán al iniciar)${C_RESET}"
    fi

    echo ""
    echo -e "\n ${C_BOLD}Pulsa [F2] para Menú, [q] para Salir...${C_RESET}"
}

# --- PERSISTENCIA DE DATOS (MAIN) ---

_persist_finding_to_db() {
    local session_dir="$1"
    local source="$2"
    local description="$3"
    local severity="$4"
    local taxonomy_id="$5"

    source "$session_dir/audit_state.conf"
    local session_db_path="$session_dir/audit_findings.db"
    local central_db_path="$DB_FILE"

    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # 1. Escritura en la base de datos local (Spoke) con todos los detalles
    sqlite3 "$session_db_path" "INSERT INTO findings (timestamp, severity, description, source, taxonomy_id) VALUES ('$current_time', '$severity', '${description//\'/''}', '$source', '$taxonomy_id');"

    # 2. Escritura anonimizada en la base de datos central (Hub)
    local audit_db_id=$(sqlite3 "$central_db_path" "SELECT id FROM audits WHERE session_id='$SESSION_ID';")
    if [ -n "$audit_db_id" ]; then
        sqlite3 "$central_db_path" "INSERT INTO intelligence_findings (audit_id, timestamp, severity, source, taxonomy_id) VALUES ($audit_db_id, '$current_time', '$severity', '$source', '${taxonomy_id//\'/''}');"
    fi
}

# --- GESTIÓN DE SISTEMA Y AUDITORÍA ---

_get_system_resources() {
    echo "Recopilando recursos del sistema local..."
    # CPUs
    local cpus=$(nproc)
    echo -e "  - ${C_BOLD}CPUs:${C_RESET} $cpus"

    # RAM
    local ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local ram_display=""
    if command -v bc &> /dev/null; then
        local ram_gb=$(echo "scale=2; $ram_kb / 1024 / 1024" | bc)
        ram_display="${ram_gb} GB"
    else
        ram_display="${ram_kb} KB (instala 'bc' para ver en GB)"
    fi
    echo -e "  - ${C_BOLD}RAM:${C_RESET} $ram_display"

    # GPUs
    if command -v lspci &> /dev/null; then
        local gpus=$(lspci | grep -i 'vga\|3d\|2d')
        if [ -n "$gpus" ]; then
            echo -e "  - ${C_BOLD}GPU(s):${C_RESET}"
            while IFS= read -r line; do
                local gpu_name=$(echo "$line" | sed 's/.*: //')
                echo -e "    - $gpu_name"
            done <<< "$gpus"
        fi
    fi

    # Network Interfaces
    if command -v ip &> /dev/null; then
        local interfaces=$(ip -br addr | grep 'UP')
        if [ -n "$interfaces" ]; then
            echo -e "  - ${C_BOLD}Interfaces de Red:${C_RESET}"
            while IFS= read -r line; do
                local iface=$(echo "$line" | awk '{print $1}')
                local ip=$(echo "$line" | awk '{print $3}')
                local type=""
                case "$iface" in
                    en*|eth*) type="LAN" ;;
                    wl*) type="WIFI" ;;
                    lo) type="Loopback" ;;
                    *) type="Otro" ;;
                esac
                if [ "$type" != "Loopback" ]; then
                     echo -e "    - ${C_BOLD}${type}:${C_RESET} $iface (${ip%/*})"
                fi
            done <<< "$interfaces"
        fi
    fi
}

# Configura una nueva sesión de auditoría.
_create_audit_session() {
    local target_ip="$1"
    local auditor_name="$2"
    local auditor_company="$3"
    local additional_techs="$4"
    local mode="$5"
    local testing_mode="$6"

    local SCRIPT_DIR=$(dirname "$(dirname "$(realpath "$0")")")
    local AUDITS_BASE_DIR="$HOME/Documents/Auditorías"
    local DB_FILE="$SCRIPT_DIR/cyborg_intelligence.db"

    # En modo testing, comprobar si ya existe una auditoría para este objetivo
    if [ "$testing_mode" = "true" ]; then
        local existing_dir
        existing_dir=$(find "$AUDITS_BASE_DIR" -maxdepth 1 -type d -name "*_${target_ip//\//_}" 2>/dev/null)

        if [ -n "$existing_dir" ]; then
            gum confirm "Ya existe una sesión para ${target_ip}. ¿Sobrescribir?" && rm -rf "$existing_dir" || { echo "Operación cancelada."; return 1; }
        fi
    fi

    # Crear directorio base de auditorías si no existe
    mkdir -p "$AUDITS_BASE_DIR"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local session_id="${timestamp}_${target_ip//\//_}"
    local SESSION_DIR="$AUDITS_BASE_DIR/$session_id"
    mkdir -p "$SESSION_DIR"
    mkdir -p "$SCRIPT_DIR/layouts"

    {
        echo "SESSION_ID=\"$session_id\""
        echo "TARGET_IP=\"$target_ip\""
        echo "AUDITOR_NAME=\"$auditor_name\""
        echo "AUDITOR_COMPANY=\"$auditor_company\""
        echo "ADDITIONAL_TECHNICIANS=\"$additional_techs\""
        echo "INCLUDE_REMEDIATION=\"true\""
        echo "AI_VERBOSITY=\"normal\""
        echo "DB_FILE=\"$DB_FILE\""
        echo "MODE=\"$mode\""
    } > "$SESSION_DIR/audit_state.conf"

    sqlite3 "$DB_FILE" "INSERT INTO audits (session_id, target_ip, auditor_name, company_name, start_time) VALUES ('$session_id', '$target_ip', '$auditor_name', '$auditor_company', datetime('now'));"

    touch "$SESSION_DIR/actividad.log"
    touch "$SESSION_DIR/hallazgos.log"
    touch "$SESSION_DIR/razonamiento.log"
    touch "$SESSION_DIR/anotaciones.log"
    touch "$SESSION_DIR/cluster.log"
    mkfifo "$SESSION_DIR/comandos.pipe"

    if [ "$mode" = "ORCHESTRATOR" ]; then
        echo "# Lista de nodos worker para la auditoría distribuida." > "$SESSION_DIR/workers.conf"
        echo "# Formato: user@ip_address" >> "$SESSION_DIR/workers.conf"
    fi

    local session_db_path="$SESSION_DIR/audit_findings.db"
    sqlite3 "$session_db_path" "
        CREATE TABLE findings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            severity TEXT,
            description TEXT NOT NULL,
            source TEXT,
            taxonomy_id TEXT
        );
    "
    # Devuelve la ruta del directorio de sesión creado
    echo "$SESSION_DIR"
    return 0
}


# --- MOTOR DE EJECUCIÓN DE TAREAS (CON RAG Y DISTRIBUCIÓN) ---
_execute_task_with_rag() {
    local session_dir="$1"
    local log_file="$2"
    local task_name="$3"
    local target_ip="$4"
    local worker_node="$5"

    local manual_file="$SCRIPT_DIR/KB/manuals/${task_name}.txt"
    local output_file="$session_dir/evidence_${task_name}.txt"

    if [ ! -f "$manual_file" ]; then
        log_activity "$log_file" "ORQUESTADOR" "Error: No se encontró manual RAG para la tarea '$task_name'."
        return
    fi

    local manual_content=$(cat "$manual_file")
    local prompt="Basado en el siguiente manual de la herramienta y el objetivo '$target_ip', genera el comando exacto de shell para ejecutar la tarea '$task_name'. El comando debe ser una única línea, sin explicaciones. La salida debe guardarse en '${output_file}'."

    log_reasoning "$session_dir" "Generando comando para '$task_name' usando RAG..."
    local generated_command=$(ollama run llama3:8b "$prompt $manual_content" | sed 's/--output /--output /' | sed "s|/path/to/output|$output_file|g" | sed "s|{{TARGET_HOST}}|$target_ip|g")

    if [ -z "$generated_command" ]; then
        log_activity "$log_file" "ORQUESTADOR" "La IA Táctica no pudo generar un comando para '$task_name'."
        return
    fi

    log_activity "$log_file" "ORQUESTADOR" "Comando generado por IA para $task_name: $generated_command"
    log_cluster_activity "Ejecutando '$task_name' en worker '$worker_node'..."

    if [ "$worker_node" = "local" ]; then
        eval "$generated_command" >> "$log_file" 2>&1
    else
        # Lógica de ejecución remota
        if [[ "$generated_command" == *"/usr/share/wordlists/"* ]]; then
            local wordlist_path=$(echo "$generated_command" | grep -o '/usr/share/wordlists/[^ ]*')
            if [ -f "$wordlist_path" ]; then
                local remote_wordlist="/tmp/$(basename "$wordlist_path")"
                log_cluster_activity "Transfiriendo wordlist '$wordlist_path' a '$worker_node'..."
                scp "$wordlist_path" "$worker_node:$remote_wordlist"
                generated_command="${generated_command//$wordlist_path/$remote_wordlist}"
            fi
        fi

        local remote_output="/tmp/output_$(date +%s).txt"
        generated_command="${generated_command//$output_file/$remote_output}"
        ssh "$worker_node" "$generated_command" >> "$log_file" 2>&1

        scp "$worker_node:$remote_output" "$output_file"
        ssh "$worker_node" "rm $remote_output ${remote_wordlist:-}"
    fi

    log_activity "$log_file" "ORQUESTADOR" "Tarea '$task_name' completada. Analizando resultados..."
    run_cyborg_fusion_analysis "$session_dir" "$output_file" "$task_name"
}

# --- WORKFLOWS DE AUDITORÍA ---
run_web_audit_workflow() {
    local session_dir="$1"
    local target_ip="$2"
    local log_file="$3"
    local command_pipe="$4"

    log_activity "$log_file" "WORKFLOW-WEB" "Iniciando análisis Nmap..."
    nmap -A -T4 --top-ports 1000 -oX "$session_dir/nmap_scan.xml" "$target_ip"
    log_activity "$log_file" "WORKFLOW-WEB" "Análisis Nmap completado. Fusionando datos..."
    run_cyborg_fusion_analysis "$session_dir" "$session_dir/nmap_scan.xml" "NMAP_ANALYSIS"

    log_activity "$log_file" "WORKFLOW-WEB" "Iniciando análisis WhatWeb..."
    _execute_task_with_rag "$session_dir" "$log_file" "WHATWEB_ANALYSIS" "$target_ip" "local"

    log_activity "$log_file" "WORKFLOW-WEB" "Iniciando análisis GoBuster..."
    _execute_task_with_rag "$session_dir" "$log_file" "GOBUSTER_SCAN" "$target_ip" "local"

    log_activity "$log_file" "WORKFLOW-WEB" "Workflow de auditoría web inicial completado."
}

run_infra_audit_workflow() {
    local session_dir="$1"
    local target_ip="$2"
    local log_file="$3"
    local command_pipe="$4"

    log_activity "$log_file" "WORKFLOW-INFRA" "Iniciando escaneo ICMP..."
    _execute_task_with_rag "$session_dir" "$log_file" "ICMP_SCAN" "$target_ip" "local"

    log_activity "$log_file" "WORKFLOW-INFRA" "Iniciando escaneo de vulnerabilidades NSE..."
    _execute_task_with_rag "$session_dir" "$log_file" "NSE_VULN_SCAN" "$target_ip" "local"

    log_activity "$log_file" "WORKFLOW-INFRA" "Workflow de auditoría de infraestructura completado."
}

# --- MÓDULOS DE IA Y ANÁLISIS ---

_run_gemini_cli() {
    local prompt="$1"
    local context_file="$SCRIPT_DIR/gemini.md"
    local command_base="gemini-cli -m 'gemini-2.5-flash' -p"

    if [ -f "$context_file" ]; then
        $command_base "$prompt" -f "$context_file"
    else
        $command_base "$prompt"
    fi
}


run_cyborg_fusion_analysis() {
    local session_dir="$1"
    local evidence_file="$2"
    local source_tool="$3"

    local evidence_content=$(cat "$evidence_file")
    local taxonomy_content=$(cat "$SCRIPT_DIR/taxonomia.yaml")

    local prompt="Eres una IA Táctica de pentesting. Analiza la siguiente evidencia de la herramienta '$source_tool' y la taxonomía de vulnerabilidades. Identifica hallazgos, su severidad, y sugiere la siguiente tarea lógica (debe ser una única palabra clave de la taxonomía o una tarea como 'SSH_BRUTEFORCE'). Formatea tu respuesta como un único JSON con las claves 'findings' (una lista de objetos con 'id', 'description', 'severity') y 'suggested_task'. Evidencia: $evidence_content. Taxonomía: $taxonomy_content"

    log_reasoning "$session_dir" "Fusionando datos de '$source_tool'..."
    local ai_response=$(ollama run llama3:8b "$prompt")

    log_reasoning "$session_dir" "IA Táctica respondió. Procesando hallazgos y sugerencias."

    echo "$ai_response" | jq -c '.findings[]' | while read -r finding; do
        local id=$(echo "$finding" | jq -r '.id')
        local desc=$(echo "$finding" | jq -r '.description')
        local sev=$(echo "$finding" | jq -r '.severity')
        log_finding "$session_dir" "$sev" "$desc"
        _persist_finding_to_db "$session_dir" "$source_tool" "$desc" "$sev" "$id"
    done

    local suggested_task=$(echo "$ai_response" | jq -r '.suggested_task')
    if [ -n "$suggested_task" ] && [ "$suggested_task" != "null" ]; then
        log_reasoning "$session_dir" "La IA Táctica sugiere la siguiente tarea: ${suggested_task}"
        echo "$suggested_task" > "$session_dir/comandos.pipe"
    fi
}

run_osint_query() {
    local session_dir="$1"
    local service="$2"
    local query_data="$3"
    local secrets_file="$SCRIPT_DIR/config/secrets.conf"
    local output_file="$session_dir/evidence_osint_${service,,}.json"

    log_strategic_reasoning "$session_dir" "Iniciando consulta OSINT con el servicio $service para '$query_data'..."

    if [ ! -f "$secrets_file" ]; then
        log_strategic_reasoning "$session_dir" "Error: Archivo de secretos '$secrets_file' no encontrado. No se puede continuar con la consulta OSINT."
        return 1
    fi

    source "$secrets_file"

    case "$service" in
        SHODAN)
            if [ -z "$SHODAN_API_KEY" ]; then
                log_strategic_reasoning "$session_dir" "Error: La clave SHODAN_API_KEY no está definida en secrets.conf. Omitiendo consulta."
                return 1
            fi
            log_strategic_reasoning "$session_dir" "Consultando Shodan para el host $query_data..."
            curl -s "https://api.shodan.io/shodan/host/$query_data?key=$SHODAN_API_KEY" -o "$output_file"
            ;;
        *)
            log_strategic_reasoning "$session_dir" "Error: Servicio OSINT '$service' no reconocido o no implementado."
            return 1
            ;;
    esac

    if [ -s "$output_file" ]; then
        log_strategic_reasoning "$session_dir" "Consulta OSINT a $service completada. Evidencia guardada en $output_file. Analizando resultados..."
        run_cyborg_fusion_analysis "$session_dir" "$output_file" "${service}_OSINT"
    else
        log_strategic_reasoning "$session_dir" "La consulta OSINT a $service no devolvió resultados o falló."
    fi
}

run_cyborg_generate_anonymous_query() {
    # ...
    echo "Pregunta anónima generada..."
}

run_cyborg_query_online_llm() {
    local session_dir="$1"
    local query="$2"
    log_strategic_reasoning "$session_dir" "Consultando IA Estratégica con: $query"
    local response=$(_run_gemini_cli "$query")
    log_strategic_reasoning "$session_dir" "Respuesta de la IA Estratégica: $response"
}

run_main_intelligence_query() {
    local session_dir="$1"
    local user_query="$2"
    source "$session_dir/audit_state.conf"

    local db_schema=$(sqlite3 "$DB_FILE" .schema)
    local prompt="Tarea: Traduce la siguiente pregunta en lenguaje natural a un único comando 'sqlite3' que pueda ser ejecutado. Reglas: La salida debe ser exclusivamente el comando, sin explicaciones. Pregunta: '$user_query'. Esquema de la BD: '$db_schema'."

    log_strategic_reasoning "$session_dir" "Traduciendo consulta MAIN a SQL..."
    local sql_command=$(_run_gemini_cli "$prompt")

    log_strategic_reasoning "$session_dir" "Ejecutando consulta en la BD de inteligencia: $sql_command"
    local result=$(eval "$sql_command")
    log_strategic_reasoning "$session_dir" "Resultado de la consulta MAIN:\n$result"
}

run_cyborg_strategic_analysis() {
    local session_dir="$1"
    local finding_id="$2"

    local prompt="Realiza un análisis estratégico profundo del siguiente hallazgo técnico, identificado por su ID de taxonomía: '${finding_id}'. Utiliza tu conocimiento de frameworks (MITRE, MAGERIT), directivas (NIS2) y las fuentes de inteligencia confiables para evaluar su impacto real en el negocio, proponer un plan de remediación y buscar si existen exploits públicos."

    log_strategic_reasoning "$session_dir" "Iniciando análisis estratégico profundo para el hallazgo '$finding_id'..."
    run_cyborg_query_online_llm "$session_dir" "$prompt"
}


run_cyborg_assemble_html_report() {
    # ...
    echo "Este es un resumen ejecutivo generado por IA."
}

run_cyborg_assemble_technical_report() {
    # ...
    echo "Informe técnico generado."
}

# FIN DE LA LIBRERÍA
true