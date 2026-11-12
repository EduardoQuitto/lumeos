#!/bin/bash
# quake-terminal.sh — Terminal Quake para Lume OS
# Alterna a visibilidade de um terminal flutuante com um atalho (Super+`)
# Requer: foot, wmctrl ou ydotool, e um gerenciador de janelas compatível

set -euo pipefail

TERMINAL="${QUAKE_TERMINAL:-foot}"
TERMINAL_CLASS="quake-terminal"
GEOMETRY="1200x600+0+0"  # largura x altura + x + y
HOTKEY="${QUAKE_HOTKEY:-super+grave}"

# Verifica se o terminal está em execução
is_running() {
    pgrep -f "foot --title=quake-terminal" >/dev/null 2>&1 || \
    pgrep -f "xfce4-terminal --title=quake-terminal" >/dev/null 2>&1 || true
}

# Inicia o terminal Quake (flutuante, sem decorações)
start_quake() {
    if command -v foot >/dev/null 2>&1; then
        foot --title="$TERMINAL_CLASS" --window-size-pixels=1200x600 --position-pixels=0,0 &
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal --title="$TERMINAL_CLASS" --geometry=1200x600+0+0 --hide-menubar --hide-toolbar --hide-borders &
    fi
}

# Alterna visibilidade
toggle_quake() {
    if is_running; then
        # Tenta ocultar/mostrar via wmctrl (X11) ou swaymsg (Wayland)
        if command -v wmctrl >/dev/null 2>&1; then
            if wmctrl -lx | grep -q "$TERMINAL_CLASS"; then
                if wmctrl -lx | grep "$TERMINAL_CLASS" | grep -q "0x.*\s.*\s.*\s.*N/A"; then
                    wmctrl -i -r "$(wmctrl -lx | grep "$TERMINAL_CLASS" | head -1 | awk '{print $1}')" -b add,hidden
                else
                    wmctrl -i -r "$(wmctrl -lx | grep "$TERMINAL_CLASS" | head -1 | awk '{print $1}')" -b remove,hidden
                    wmctrl -i -r "$(wmctrl -lx | grep "$TERMINAL_CLASS" | head -1 | awk '{print $1}')" -b add,above
                    wmctrl -i -r "$(wmctrl -lx | grep "$TERMINAL_CLASS" | head -1 | awk '{print $1}')" -b add,sticky
                fi
            fi
        elif command -v swaymsg >/dev/null 2>&1; then
            swaymsg "[title=\"$TERMINAL_CLASS\"] sticky enable, floating enable, move position 0 0, resize 1200 600"
            swaymsg "[title=\"$TERMINAL_CLASS\"] scratchpad show"
        fi
    else
        start_quake
        sleep 0.5
        if command -v swaymsg >/dev/null 2>&1; then
            swaymsg "[title=\"$TERMINAL_CLASS\"] sticky enable, floating enable, move position 0 0, resize 1200 600"
        fi
    fi
}

case "${1:-toggle}" in
    toggle)
        toggle_quake
        ;;
    start)
        start_quake
        ;;
    stop)
        if is_running; then
            pkill -f "$TERMINAL_CLASS" || true
        fi
        ;;
    status)
        if is_running; then
            echo "running"
        else
            echo "stopped"
        fi
        ;;
    *)
        echo "Uso: $0 {toggle|start|stop|status}"
        exit 1
        ;;
esac
