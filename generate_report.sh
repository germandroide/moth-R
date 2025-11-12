#!/bin/bash
# @ts-nocheck
# CYBorg v2.5 - Generador de Informes

SESSION_DIR=$1

if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido."
    exit 1
fi

# Cargar la librería para acceder a la función de ensamblaje por IA
source "$(dirname "$0")/lib_cyborg.sh"

# Archivos de origen y destino
TEMPLATE_FILE="$(dirname "$0")/templates/informe_plantilla.html"
NMAP_EVIDENCE_TEMPLATE="$(dirname "$0")/templates/nmap_to_html.xsl"
CONFIG_FILE="$SESSION_DIR/audit_state.conf"
FINDINGS_FILE="$SESSION_DIR/hallazgos.log"
ANNOTATIONS_FILE="$SESSION_DIR/anotaciones.log"
LOG_FILE="$SESSION_DIR/actividad.log"

# --- Definición de Nombres de Archivos de Salida ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CLIENT_REPORT_FILE="$SESSION_DIR/informe_auditoria_cliente_${TIMESTAMP}.html"
TECHNICAL_REPORT_FILE="$SESSION_DIR/informe_tecnico_auditoria_${TIMESTAMP}.md"


# Utilizar la función de logging centralizada
log_report_activity() {
    log_activity "$LOG_FILE" "GENERADOR" "$1"
}