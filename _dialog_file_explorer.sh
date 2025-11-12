#!/bin/bash
# CYBorg v2.5 - Diálogo Interactivo: Explorador de Archivos

# Cargar la librería para colores y estilos.
source "$(dirname "$0")/lib_cyborg.sh"

# El primer argumento es el directorio desde donde empezar a buscar.
# Si no se proporciona, se usa el directorio home del usuario.
START_PATH="${1:-$HOME}"

# --- INVOCACIÓN DEL EXPLORADOR DE ARCHIVOS ---
# Usamos 'gum file' que nos proporciona esta funcionalidad de forma nativa.
# - --directory: Abre en modo de selección de directorio.
# - --file: Abre en modo de selección de archivo (por defecto).
# - --cursor: Cambia el indicador del elemento seleccionado.
# - --all: Muestra archivos ocultos (dotfiles).

# Lo configuramos para que empiece en la ruta especificada.
# La salida del comando será la ruta del archivo seleccionado.
selected_file=$(gum file --cursor "›" --all "$START_PATH")

# --- SALIDA ---
# Si el usuario seleccionó un archivo (la salida no está vacía),
# lo imprimimos a la salida estándar para que el script que lo llamó
# pueda capturarlo. Si el usuario canceló (presionando ESC),
# la salida estará vacía y no se imprimirá nada.
if [ -n "$selected_file" ]; then
    echo "$selected_file"
fi
