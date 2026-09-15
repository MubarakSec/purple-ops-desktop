#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
backup_root="$HOME/.local/state/purple-ops-backups/$(date +%Y%m%d-%H%M%S)"
skip_packages=0
skip_system_theme=0

usage() {
    cat <<'EOF'
Usage: ./install.sh [--skip-packages] [--skip-system-theme]

Restores the Purple Ops terminal and GNOME desktop. Existing managed files are
copied to ~/.local/state/purple-ops-backups before they are replaced.
EOF
}

for argument in "$@"; do
    case "$argument" in
        --skip-packages) skip_packages=1 ;;
        --skip-system-theme) skip_system_theme=1 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$argument" >&2; usage >&2; exit 2 ;;
    esac
done

[[ "$EUID" -ne 0 ]] || {
    printf 'Run this script as your normal desktop user, not root.\n' >&2
    exit 1
}

backup_path() {
    local path="$1"
    [[ -e "$path" || -L "$path" ]] || return 0
    local relative="${path#"$HOME"/}"
    mkdir -p "$backup_root/$(dirname -- "$relative")"
    cp -a -- "$path" "$backup_root/$relative"
}

restore_text_tree() {
    local source="$1"
    local destination="$2"
    [[ -d "$source" ]] || return 0
    mkdir -p "$destination"
    cp -a -- "$source/." "$destination/"
    while IFS= read -r -d '' source_file; do
        relative="${source_file#"$source"/}"
        destination_file="$destination/$relative"
        file --brief --mime "$destination_file" | grep -q '^text/' || continue
        sed -i "s#__HOME__#${HOME//\#/\\#}#g" "$destination_file"
    done < <(find "$source" -type f -print0)
}

if (( ! skip_packages )); then
    sudo -v
    sudo apt-get update
    mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' "$repo_root/packages/apt.txt")
    sudo apt-get install -y "${packages[@]}"
fi

(cd "$repo_root/archives" && sha256sum --check SHA256SUMS)

mkdir -p "$backup_root"

for path in \
    "$HOME/.bashrc" \
    "$HOME/.profile" \
    "$HOME/.vimrc" \
    "$HOME/.gitconfig" \
    "$HOME/.config/kitty" \
    "$HOME/.config/tmux" \
    "$HOME/.config/yazi" \
    "$HOME/.config/btop" \
    "$HOME/.config/lazygit" \
    "$HOME/.config/shell" \
    "$HOME/.config/blesh" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/ubuntu-xdg-terminals.list" \
    "$HOME/.config/nvim" \
    "$HOME/.config/systemd/user/wallpaper-changer.service" \
    "$HOME/.config/systemd/user/wallpaper-changer.timer" \
    "$HOME/.config/autostart/boost-volume.desktop" \
    "$HOME/.config/autostart/org.gnome.DejaDup.Monitor.desktop" \
    "$HOME/.local/share/purple-ops" \
    "$HOME/.local/share/sounds/PurpleOps" \
    "$HOME/.local/share/blesh" \
    "$HOME/.themes/catppuccin-mocha-lavender-standard+default" \
    "$HOME/.icons/Tela-circle" \
    "$HOME/.icons/Tela-circle-dark" \
    "$HOME/.icons/Bibata-Modern-Classic" \
    "$HOME/.wallpaper/linux.png" \
    "$HOME/.wallpaper/lockscreen.jpg" \
    "$HOME/.local/bin/kitty-workspace" \
    "$HOME/.local/bin/tmux-explorer-pane" \
    "$HOME/.local/bin/tmux-explorer-toggle" \
    "$HOME/.local/bin/tmux-fuzzy-open" \
    "$HOME/.local/bin/tmux-lazygit" \
    "$HOME/.local/bin/change-wallpaper.sh" \
    "$HOME/.local/bin/yazi" \
    "$HOME/.local/bin/ya" \
    "$HOME/.local/bin/fd" \
    "$HOME/.local/bin/bat"
do
    backup_path "$path"
done

for font in "$HOME"/.local/share/fonts/JetBrainsMonoNerdFontMono-*.ttf; do
    [[ -e "$font" ]] && backup_path "$font"
done

for path in \
    "$HOME/.bashrc" \
    "$HOME/.profile" \
    "$HOME/.vimrc" \
    "$HOME/.gitconfig" \
    "$HOME/.config/kitty" \
    "$HOME/.config/tmux" \
    "$HOME/.config/yazi" \
    "$HOME/.config/btop" \
    "$HOME/.config/lazygit" \
    "$HOME/.config/shell" \
    "$HOME/.config/blesh" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/ubuntu-xdg-terminals.list"
do
    rm -rf -- "$path"
done

restore_text_tree "$repo_root/home" "$HOME"

mkdir -p "$HOME/.local/share/fonts" "$HOME/.wallpaper"
cp -a -- "$repo_root/assets/fonts/." "$HOME/.local/share/fonts/"
install -m 0644 "$repo_root/assets/wallpapers/desktop.png" "$HOME/.wallpaper/linux.png"
install -m 0644 "$repo_root/assets/wallpapers/lockscreen.jpg" "$HOME/.wallpaper/lockscreen.jpg"

rm -rf -- \
    "$HOME/.local/share/purple-ops" \
    "$HOME/.local/share/sounds/PurpleOps" \
    "$HOME/.local/share/blesh" \
    "$HOME/.themes/catppuccin-mocha-lavender-standard+default" \
    "$HOME/.icons/Tela-circle" \
    "$HOME/.icons/Tela-circle-dark" \
    "$HOME/.icons/Bibata-Modern-Classic"
restore_text_tree "$repo_root/assets/purple-ops" "$HOME/.local/share/purple-ops"
cp -a -- "$repo_root/assets/PurpleOps" "$HOME/.local/share/sounds/PurpleOps"

tar -C "$HOME" -xJf "$repo_root/archives/desktop-themes.tar.xz"
for extension in \
    Vitals@CoreCoding.com \
    blur-my-shell@aunetx \
    clipboard-indicator@tudmotu.com \
    hidetopbar@mathieu.bidon.ca \
    just-perfection-desktop@just-perfection
do
    backup_path "$HOME/.local/share/gnome-shell/extensions/$extension"
    rm -rf -- "$HOME/.local/share/gnome-shell/extensions/$extension"
done
tar -C "$HOME/.local/share" -xJf "$repo_root/archives/gnome-shell-extensions.tar.xz"
tar -C "$HOME/.local/share" -xJf "$repo_root/archives/blesh-nightly.tar.xz"
tar -C "$HOME/.local/bin" -xJf "$repo_root/archives/yazi-26.5.6-linux-amd64.tar.xz"

# Ubuntu names these two commands differently from the cross-platform names
# used by the terminal configuration.
ln -sfn /usr/bin/fdfind "$HOME/.local/bin/fd"
ln -sfn /usr/bin/batcat "$HOME/.local/bin/bat"

if [[ -d "$HOME/.config/nvim" ]]; then
    rm -rf -- "$HOME/.config/nvim"
fi
if ! git clone git@github.com:MubarakSec/nvim-config.git "$HOME/.config/nvim"; then
    printf 'Neovim clone failed. Authenticate GitHub, then run:\n' >&2
    printf '  git clone git@github.com:MubarakSec/nvim-config.git ~/.config/nvim\n' >&2
fi

load_dconf() {
    local path="$1"
    local file="$2"
    sed "s#__HOME__#${HOME//\#/\\#}#g" "$repo_root/dconf/$file" | dconf load "$path"
}

load_dconf /org/gnome/desktop/interface/ desktop-interface.ini
load_dconf /org/gnome/desktop/background/ desktop-background.ini
load_dconf /org/gnome/desktop/screensaver/ desktop-screensaver.ini
load_dconf /org/gnome/desktop/sound/ desktop-sound.ini
load_dconf /org/gnome/desktop/wm/preferences/ wm-preferences.ini
load_dconf /org/gnome/desktop/input-sources/ input-sources.ini
load_dconf /org/gnome/desktop/peripherals/ peripherals.ini
load_dconf /org/gnome/desktop/session/ session.ini
load_dconf /org/gnome/desktop/privacy/ privacy.ini
load_dconf /org/gnome/mutter/ mutter.ini
load_dconf /org/gnome/settings-daemon/plugins/power/ power.ini
load_dconf /org/gnome/shell/ shell-core.ini
load_dconf /org/gnome/shell/extensions/blur-my-shell/ extension-blur-my-shell.ini
load_dconf /org/gnome/shell/extensions/clipboard-indicator/ extension-clipboard-indicator.ini
load_dconf /org/gnome/shell/extensions/dash-to-dock/ extension-dash-to-dock.ini
load_dconf /org/gnome/shell/extensions/just-perfection/ extension-just-perfection.ini
load_dconf /org/gnome/shell/extensions/tiling-assistant/ extension-tiling-assistant.ini
load_dconf /org/gnome/shell/extensions/user-theme/ extension-user-theme.ini
load_dconf /org/gnome/shell/extensions/vitals/ extension-vitals.ini
load_dconf /org/gnome/shell/extensions/hidetopbar/ extension-hidetopbar.ini
load_dconf /org/gnome/desktop/wm/keybindings/ wm-keybindings.ini
load_dconf /org/gnome/shell/keybindings/ shell-keybindings.ini
load_dconf /org/gnome/settings-daemon/plugins/color/ color.ini

gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.wallpaper/linux.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.wallpaper/linux.png"
gsettings set org.gnome.desktop.screensaver picture-uri "file://$HOME/.wallpaper/lockscreen.jpg"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Primary><Alt>t']"

fc-cache -f
systemctl --user daemon-reload
systemctl --user enable --now wallpaper-changer.timer

if (( ! skip_system_theme )); then
    sudo -v
    sudo "$HOME/.local/share/purple-ops/install-system.sh"
fi

printf '\nPurple Ops restored.\n'
printf 'Previous managed files: %s\n' "$backup_root"
printf 'Log out and back in once so GNOME reloads extensions, fonts, and themes.\n'
