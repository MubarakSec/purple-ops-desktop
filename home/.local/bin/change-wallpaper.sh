#!/bin/bash

WALLPAPER_DIR="$HOME/.wallpaper"
LOG_FILE="$HOME/.cache/wallpaper-changer.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

list() {
    find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) -printf '%f\n' | sort
}

set_wallpaper() {
    local name="$1"
    local pic
    pic=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) -name "$name" 2>/dev/null | head -1)
    if [ -z "$pic" ]; then
        log "ERROR: '$name' not found"
        echo "Wallpaper '$name' not found. Use --list to see available." >&2
        exit 1
    fi
    apply "$pic"
}

random() {
    local pic
    pic=$(find "$WALLPAPER_DIR" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) 2>/dev/null | shuf -n 1)
    if [ -z "$pic" ]; then
        log "ERROR: No wallpapers in $WALLPAPER_DIR"
        echo "No wallpapers found." >&2
        exit 1
    fi
    apply "$pic"
}

apply() {
    local pic="$1"
    gsettings set org.gnome.desktop.background picture-uri "file://$pic" 2>>"$LOG_FILE" && \
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$pic" 2>>"$LOG_FILE"
    if [ $? -eq 0 ]; then
        log "OK: $(basename "$pic")"
        echo "Wallpaper set to $(basename "$pic")"
    else
        log "FAILED: $pic"
        exit 1
    fi
}

case "${1:-}" in
    --list|-l) list ;;
    --set|-s)
        if [ -z "${2:-}" ]; then echo "Usage: $0 --set <filename>" >&2; exit 1; fi
        set_wallpaper "$2"
        ;;
    --help|-h)
        echo "Usage: $0 [OPTION]"
        echo "  (no arg)   Set random wallpaper"
        echo "  --list,-l  List available wallpapers"
        echo "  --set,-s   Set specific wallpaper by filename"
        echo "  --help,-h  Show this help"
        ;;
    *) random ;;
esac
