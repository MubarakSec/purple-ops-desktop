#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
snapshot_home="$repo_root/home"
current_home="$HOME"

copy_file() {
    local source="$1"
    local relative="$2"
    [[ -f "$source" ]] || return 0
    install -D -m "$(stat -c '%a' "$source")" "$source" "$snapshot_home/$relative"
}

sync_directory() {
    local source="$1"
    local relative="$2"
    [[ -d "$source" ]] || return 0
    mkdir -p "$snapshot_home/$relative"
    rsync -a --delete --exclude='.git' -- "$source/" "$snapshot_home/$relative/"
}

dump_dconf() {
    local path="$1"
    local output="$2"
    local temporary
    temporary="$(mktemp)"
    dconf dump "$path" > "$temporary"
    sed "s#${current_home//\#/\\#}#__HOME__#g" "$temporary" > "$repo_root/dconf/$output"
    rm -f -- "$temporary"
}

for file in .bashrc .profile .vimrc .gitconfig; do
    copy_file "$current_home/$file" "$file"
done

for directory in kitty tmux yazi btop lazygit shell blesh; do
    sync_directory "$current_home/.config/$directory" ".config/$directory"
done
copy_file "$current_home/.config/starship.toml" ".config/starship.toml"
copy_file "$current_home/.config/ubuntu-xdg-terminals.list" ".config/ubuntu-xdg-terminals.list"
copy_file \
    "$current_home/.config/systemd/user/wallpaper-changer.service" \
    ".config/systemd/user/wallpaper-changer.service"
copy_file \
    "$current_home/.config/systemd/user/wallpaper-changer.timer" \
    ".config/systemd/user/wallpaper-changer.timer"
copy_file \
    "$current_home/.config/autostart/boost-volume.desktop" \
    ".config/autostart/boost-volume.desktop"
copy_file \
    "$current_home/.config/autostart/org.gnome.DejaDup.Monitor.desktop" \
    ".config/autostart/org.gnome.DejaDup.Monitor.desktop"

for script in \
    kitty-workspace \
    tmux-explorer-pane \
    tmux-explorer-toggle \
    tmux-fuzzy-open \
    tmux-lazygit \
    change-wallpaper.sh
do
    copy_file "$current_home/.local/bin/$script" ".local/bin/$script"
done

for font in "$current_home"/.local/share/fonts/JetBrainsMonoNerdFontMono-*.ttf; do
    [[ -f "$font" ]] || continue
    install -D -m 0644 "$font" "$repo_root/assets/fonts/$(basename -- "$font")"
done

sync_directory "$current_home/.local/share/purple-ops" "../assets/purple-ops"
sync_directory "$current_home/.local/share/sounds/PurpleOps" "../assets/PurpleOps"

mkdir -p "$repo_root/dconf"
dump_dconf /org/gnome/desktop/interface/ desktop-interface.ini
dump_dconf /org/gnome/desktop/background/ desktop-background.ini
dump_dconf /org/gnome/desktop/screensaver/ desktop-screensaver.ini
dump_dconf /org/gnome/desktop/sound/ desktop-sound.ini
dump_dconf /org/gnome/desktop/wm/preferences/ wm-preferences.ini
dump_dconf /org/gnome/desktop/input-sources/ input-sources.ini
dump_dconf /org/gnome/desktop/peripherals/ peripherals.ini
dump_dconf /org/gnome/desktop/session/ session.ini
dump_dconf /org/gnome/desktop/privacy/ privacy.ini
dump_dconf /org/gnome/mutter/ mutter.ini
dump_dconf /org/gnome/settings-daemon/plugins/power/ power.ini
dump_dconf /org/gnome/shell/extensions/blur-my-shell/ extension-blur-my-shell.ini
dump_dconf /org/gnome/shell/extensions/clipboard-indicator/ extension-clipboard-indicator.ini
dump_dconf /org/gnome/shell/extensions/dash-to-dock/ extension-dash-to-dock.ini
dump_dconf /org/gnome/shell/extensions/just-perfection/ extension-just-perfection.ini
dump_dconf /org/gnome/shell/extensions/tiling-assistant/ extension-tiling-assistant.ini
dump_dconf /org/gnome/shell/extensions/user-theme/ extension-user-theme.ini
dump_dconf /org/gnome/shell/extensions/vitals/ extension-vitals.ini
dump_dconf /org/gnome/shell/extensions/hidetopbar/ extension-hidetopbar.ini
dump_dconf /org/gnome/desktop/wm/keybindings/ wm-keybindings.ini
dump_dconf /org/gnome/shell/keybindings/ shell-keybindings.ini
dump_dconf /org/gnome/settings-daemon/plugins/color/ color.ini
sed -i \
    "s#^picture-uri=.*#picture-uri='file://__HOME__/.wallpaper/lockscreen.jpg'#" \
    "$repo_root/dconf/desktop-screensaver.ini"

{
    printf '[/]\n'
    printf 'enabled-extensions=%s\n' \
        "$(gsettings get org.gnome.shell enabled-extensions)"
    printf 'favorite-apps=%s\n' \
        "$(gsettings get org.gnome.shell favorite-apps)"
} > "$repo_root/dconf/shell-core.ini"

wallpaper_uri="$(gsettings get org.gnome.desktop.background picture-uri)"
wallpaper="${wallpaper_uri#\\'}"
wallpaper="${wallpaper%\\'}"
wallpaper="${wallpaper#file://}"
[[ -f "$wallpaper" ]] &&
    install -D -m 0644 "$wallpaper" "$repo_root/assets/wallpapers/desktop.png"

lockscreen_uri="$(gsettings get org.gnome.desktop.screensaver picture-uri)"
lockscreen="${lockscreen_uri#\\'}"
lockscreen="${lockscreen%\\'}"
lockscreen="${lockscreen#file://}"
[[ -f "$lockscreen" ]] &&
    install -D -m 0644 "$lockscreen" "$repo_root/assets/wallpapers/lockscreen.jpg"

# Keep the source snapshot portable even when it was captured from another
# username or home directory.
while IFS= read -r -d '' file; do
    file --brief --mime "$file" | grep -q '^text/' || continue
    sed -i "s#${current_home//\#/\\#}#__HOME__#g" "$file"
done < <(find "$snapshot_home" "$repo_root/assets/purple-ops" -type f -print0)

tar -C "$current_home" -cJf "$repo_root/archives/desktop-themes.tar.xz" \
    .themes/Orchis-Purple-Dark \
    .icons/Tela-circle \
    .icons/Tela-circle-purple \
    .icons/Tela-circle-purple-dark \
    .icons/Bibata-Modern-Classic
tar -C "$current_home/.local/share" \
    -cJf "$repo_root/archives/gnome-shell-extensions.tar.xz" \
    gnome-shell/extensions/Vitals@CoreCoding.com \
    gnome-shell/extensions/blur-my-shell@aunetx \
    gnome-shell/extensions/clipboard-indicator@tudmotu.com \
    gnome-shell/extensions/hidetopbar@mathieu.bidon.ca \
    gnome-shell/extensions/just-perfection-desktop@just-perfection
tar -C "$current_home/.local/share" \
    -cJf "$repo_root/archives/blesh-nightly.tar.xz" blesh
tar -C "$current_home/.local/bin" \
    -cJf "$repo_root/archives/yazi-26.5.6-linux-amd64.tar.xz" yazi ya

(cd "$repo_root/archives" && sha256sum ./*.tar.xz > SHA256SUMS)
printf 'Purple Ops snapshot refreshed in %s\n' "$repo_root"
