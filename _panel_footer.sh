#!/bin/bash
# CYBorg v2.5 - Panel de Pie de Página (Footer)

# No necesita el SESSION_DIR porque es estático, pero lo aceptamos por consistencia.
SESSION_DIR=$1

# Cargar la librería solo para los colores.
source "$(dirname "$0")/lib_cyborg.sh"

# --- DEFINICIÓN DE ACCIONES (F-Keys) ---
# Usamos un formato que 'gum join' puede procesar fácilmente.
# Cada acción es un bloque de texto estilizado.

F1="F1 Ayuda"
F2="F2 Menú"
F3="F3 Vista"
F5="F5 Analizar"
F9="F9 Opciones"
F10="F10 Salir"

# Estilo para las teclas (ej. "F1")
KEY_STYLE="--background '#555555' --foreground '#FFFFFF' --padding '0 1'"
# Estilo para la descripción de la acción (ej. "Ayuda")
DESC_STYLE="--background '#444444' --foreground '#DDDDDD' --padding '0 1'"

# --- BUCLE DE RENDERIZADO ---
# Aunque el contenido es estático, usamos un bucle por si en el futuro
# queremos que el pie de página sea dinámico (ej. cambiar según el contexto).
while true; do

    # Componemos cada "botón"
    footer_content=()
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F1") " Ayuda")")
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F2") " Menú")")
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F3") " Vista")")
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F5") " Analizar")")
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F9") " Opciones")")
    footer_content+=("$(gum style $(gum style --bold --foreground '#FFFFFF' "F10") " Salir")")

    # Unimos todos los botones en una sola línea horizontal
    # Usamos un separador estilizado para que quede más limpio
    separator=$(gum style " │ " --foreground "$C_GRAY")

    # Renderizamos la línea completa
    # El `echo` es necesario porque 'gum join' saca el resultado por stdout
    # y queremos que se imprima en el panel.
    echo "$(gum join --align left "${footer_content[@]}")"

    # El pie de página no necesita refrescarse constantemente.
    # Dormimos 'infinity' para que solo se dibuje una vez.
    # Si se redimensiona la ventana, tmux lo redibujará automáticamente.
    sleep infinity
done
