#!/bin/bash
# CYBorg v2.5 - Panel de Pie de Página (Footer - Action Bar)

SESSION_DIR=$1
# No es estrictamente necesario aquí, pero se mantiene por consistencia.

source "$(dirname "$0")/lib_cyborg.sh"

# Función para imprimir una tecla de función formateada
print_fkey() {
    local key="$1"
    local label="$2"
    # Usamos colores invertidos para dar aspecto de botón
    echo -ne "${C_BG_BLUE}${C_BLACK} ${key} ${C_RESET}${C_BG_GRAY}${C_BLACK} ${label} ${C_RESET} "
}

# Obtener el ancho del terminal
width=$(tmux display -p '#{pane_width}')

# Limpiar la línea y dibujar la barra de acciones
printf "\r%*s" "$width" ""
printf "\r"
print_fkey "F1" "Ayuda"
print_fkey "F2" "Menú"
print_fkey "F3" "Vista"
print_fkey "F5" "Analizar"
print_fkey "F9" "Opciones"
print_fkey "q" "Salir"


# Mantener el script vivo para que el panel no se cierre
sleep infinity