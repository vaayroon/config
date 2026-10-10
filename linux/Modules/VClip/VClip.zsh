#!/usr/bin/zsh
# VClip.zsh
# Implementación de funciones para copiar contenido al portapapeles
# Author: Condor Romero, Bryan Kevin

# ─── Backend detection ────────────────────────────────────────────────────────

_vclip_copy_cmd=""
_vclip_paste_cmd=""

if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy &>/dev/null; then
  _vclip_copy_cmd="wl-copy"
  _vclip_paste_cmd="wl-paste"
elif command -v xclip &>/dev/null; then
  _vclip_copy_cmd="xclip -selection"
  _vclip_paste_cmd="xclip -selection clipboard -o"
elif command -v xsel &>/dev/null; then
  _vclip_copy_cmd="xsel --clipboard --input"
  _vclip_paste_cmd="xsel --clipboard --output"
else
  echo "[VClip] No se encontró xclip, xsel ni wl-copy." >&2
  echo "[VClip] Instala uno con: sudo apt-get install xclip" >&2
  return 1
fi

# ─── Helper interno ───────────────────────────────────────────────────────────

function _vclip_do_copy() {
  local selection="${VCLIP_SELECTION:-clipboard}"

  if [[ "$_vclip_copy_cmd" == "wl-copy" ]]; then
    wl-copy
  elif [[ "$_vclip_copy_cmd" == xclip* ]]; then
    xclip -selection "$selection"
  else
    xsel --clipboard --input
  fi
}

function _vclip_do_paste() {
  local selection="${VCLIP_SELECTION:-clipboard}"

  if [[ "$_vclip_paste_cmd" == "wl-paste" ]]; then
    wl-paste
  elif [[ "$_vclip_paste_cmd" == xclip* ]]; then
    xclip -selection "$selection" -o
  else
    xsel --clipboard --output
  fi
}

# ─── Funciones públicas ───────────────────────────────────────────────────────

# Copia stdin o uno/varios archivos al portapapeles
# Uso: vclip [archivo...]
#      echo "texto" | vclip
function vclip() {
  if [[ $# -eq 0 ]]; then
    # Leer desde stdin
    _vclip_do_copy
    echo "[VClip] Texto desde stdin copiado al portapapeles."
  else
    local file combined_output=""
    for file in "$@"; do
      if [[ ! -f "$file" ]]; then
        echo "[VClip] El archivo '$file' no existe." >&2
        return 1
      fi
      combined_output+="$(cat "$file")"$'\n'
    done
    echo -n "$combined_output" | _vclip_do_copy
    if [[ $# -eq 1 ]]; then
      echo "[VClip] Contenido de '$1' copiado al portapapeles."
    else
      echo "[VClip] Contenido de $# archivos copiado al portapapeles."
    fi
  fi
}

# Pega el contenido del portapapeles en stdout
function vpaste() {
  _vclip_do_paste
}

# Muestra el contenido del portapapeles (con paginación si está disponible)
function vclipshow() {
  local content
  content="$(_vclip_do_paste)"

  if [[ -z "$content" ]]; then
    echo "[VClip] El portapapeles está vacío."
    return 0
  fi

  echo "── Portapapeles ──────────────────────────────"
  if command -v bat &>/dev/null; then
    echo "$content" | bat --style=plain --paging=auto
  elif command -v batcat &>/dev/null; then
    echo "$content" | batcat --style=plain --paging=auto
  else
    echo "$content" | less -FX
  fi
}

# Limpia el portapapeles
function vclipclear() {
  echo -n "" | _vclip_do_copy
  echo "[VClip] Portapapeles limpiado."
}

# Muestra el backend activo y la selección configurada
function vclipinfo() {
  echo "Backend : $_vclip_copy_cmd"
  echo "Selección: ${VCLIP_SELECTION:-clipboard}"
  echo "Wayland : ${WAYLAND_DISPLAY:-no}"
}
