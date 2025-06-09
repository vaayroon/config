#!/usr/bin/env zsh
# VClip.zsh
# Implementación de funciones para copiar contenido al portapapeles usando xclip
# Author: Condor Romero, Bryan Kevin

# Verifica si xclip está instalado
if ! command -v xclip &> /dev/null; then
  echo "xclip no está instalado. Instálalo con: sudo apt-get install xclip" >&2
  return 1
fi

# Función para copiar el contenido de un archivo al portapapeles
function vclipf() {
  if [[ $# -ne 1 ]]; then
    echo "Uso: vclipf <ruta_archivo>" >&2
    return 1
  fi
  
  local path="$1"
  
  if [[ -f "$path" ]]; then
    cat "$path" | xclip -selection clipboard
    echo "Contenido de '$path' copiado al portapapeles."
  else
    echo "El archivo '$path' no existe." >&2
    return 1
  fi
}

# Función para copiar texto desde stdin o un archivo al portapapeles
function vclip() {
  if [[ $# -eq 0 ]]; then
    # Sin argumentos, leer de stdin
    xclip -selection clipboard
    echo "Texto desde stdin copiado al portapapeles."
  else
    local path="$1"
    
    if [[ -f "$path" ]]; then
      cat "$path" | xclip -selection clipboard
      echo "Contenido de '$path' copiado al portapapeles."
    else
      echo "El archivo '$path' no existe." >&2
      return 1
    fi
  fi
}

# Función para pegar el contenido del portapapeles
function vpaste() {
  xclip -selection clipboard -o
}

# Función para mostrar el contenido del portapapeles
function vclipshow() {
  echo "Contenido del portapapeles:"
  xclip -selection clipboard -o
}

# Función para limpiar el portapapeles
function vclipclear() {
  echo -n "" | xclip -selection clipboard
  echo "Portapapeles limpiado."
}
