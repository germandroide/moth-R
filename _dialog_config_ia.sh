#!/bin/bash
# CYBorg v2.5 - Diálogo Interactivo: Configuración de IA

SESSION_DIR=$1
if [ -z "$SESSION_DIR" ] || [ !-f "$SESSION_DIR/audit_state.conf" ]; then
    # No podemos configurar nada si no hay sesión o fichero de estado.
    tmux display-message "Error: No se encuentra el fichero de estado de la auditoría."
    exit 1
fi

# Cargar la librería para colores y la configuración actual.
source "$(dirname "$0")/lib_cyborg.sh"
source "$SESSION_DIR/audit_state.conf"

# --- INTERFAZ DE CONFIGURACIÓN ---

# Usaremos un bucle para poder presentar el formulario.
# Aunque en este caso se ejecuta una sola vez, la estructura es útil
# para formularios más complejos o con validación.
while true; do

    # Creamos un bloque de texto formateado para el formulario.
    # Usamos `gum join` para alinear etiquetas y valores.
    form_header=$(gum style --bold --foreground "$C_CYAN" "Configuración de Inteligencia Artificial")

    # Opción 1: Modo de IA
    # Mostramos el valor actual y las opciones.
    mode_label=$(gum style --bold "Modo de IA:")
    mode_value=$(gum style --foreground "$C_YELLOW" "$AI_MODE")
    mode_line=$(gum join --align left "$mode_label" "$mode_value")

    # Opción 2: IA Estratégica
    strategic_label=$(gum style --bold "IA Estratégica (Online):")
    strategic_value=$(gum style --foreground "$C_YELLOW" "$STRATEGIC_AI_PROVIDER")
    strategic_line=$(gum join --align left "$strategic_label" "$strategic_value")

    # Opción 3: IA Táctica
    tactical_label=$(gum style --bold "IA Táctica (Local):")
    tactical_value=$(gum style --foreground "$C_GRAY" "Ollama (automático)") # Es un valor fijo.
    tactical_line=$(gum join --align left "$tactical_label" "$tactical_value")

    # Juntamos todo en un gran bloque de texto para `gum confirm`.
    gum_prompt=$(printf "%s\n\n%s\n%s\n%s" "$form_header" "$mode_line" "$strategic_line" "$tactical_line")

    # Usamos `gum confirm` para presentar el "formulario" y preguntar si se quieren cambiar los valores.
    gum confirm "$gum_prompt" --prompt.foreground "$C_WHITE" --affirmative "Cambiar" --negative "Cancelar"

    # Si el usuario cancela (código de salida != 0), salimos del bucle.
    if [ $? -ne 0 ]; then
        tmux display-message "Configuración no modificada."
        break
    fi

    # --- LÓGICA DE MODIFICACIÓN ---

    # Pedimos al usuario que elija el nuevo modo de IA.
    new_ai_mode=$(gum choose "HYBRID" "LOCAL_ONLY")

    # Pedimos al usuario que elija el nuevo proveedor de IA Estratégica.
    new_strategic_provider=$(gum choose "GEMINI" "CLAUDE" "GPT4")

    # --- GUARDADO DE LA CONFIGURACIÓN ---

    # Usamos `sed` para reemplazar los valores en el archivo de configuración.
    # La opción -i edita el archivo "in-place".
    sed -i "s/^AI_MODE=.*/AI_MODE=\"$new_ai_mode\"/" "$SESSION_DIR/audit_state.conf"
    sed -i "s/^STRATEGIC_AI_PROVIDER=.*/STRATEGIC_AI_PROVIDER=\"$new_strategic_provider\"/" "$SESSION_DIR/audit_state.conf"

    tmux display-message "Configuración de IA guardada."

    # Salimos del bucle después de guardar.
    break
done
