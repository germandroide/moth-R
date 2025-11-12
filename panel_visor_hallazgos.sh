#!/bin/bash
# CYBorg v2.5 - Panel Visor de Hallazgos

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ ! -d "$SESSION_DIR" ]; then
    echo "Error: Se requiere un directorio de sesión válido."
    exit 1
fi

FINDINGS_FILE="$SESSION_DIR/hallazgos.log"

# Asegurarse de que el archivo existe antes de intentar seguirlo
touch "$FINDINGS_FILE"

echo "--- Visor de Hallazgos (Cliente) ---"
echo "Esperando hallazgos en: $FINDINGS_FILE"
echo "------------------------------------"

# Usar tail -f para seguir el archivo
tail -f "$FINDINGS_FILE"