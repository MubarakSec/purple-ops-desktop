#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="/tmp/purple-ops-restore-test.$$"
fake_home="$test_root/home"
legacy_home="/home/"'mobta'
trap 'rm -rf -- "$test_root"' EXIT

rm -rf -- "$test_root"
mkdir -p "$fake_home/.local/share" "$fake_home/.local/bin"
cp -a -- "$repo_root/home/." "$fake_home/"

while IFS= read -r -d '' source_file; do
    relative="${source_file#"$repo_root/home/"}"
    destination="$fake_home/$relative"
    file --brief --mime "$destination" | grep -q '^text/' || continue
    sed -i "s#__HOME__#$fake_home#g" "$destination"
done < <(find "$repo_root/home" -type f -print0)

tar -C "$fake_home" -xJf "$repo_root/archives/desktop-themes.tar.xz"
tar -C "$fake_home/.local/share" \
    -xJf "$repo_root/archives/gnome-shell-extensions.tar.xz"
tar -C "$fake_home/.local/share" \
    -xJf "$repo_root/archives/blesh-nightly.tar.xz"
tar -C "$fake_home/.local/bin" \
    -xJf "$repo_root/archives/yazi-26.5.6-linux-amd64.tar.xz"

required=(
    .bashrc
    .config/kitty/kitty.conf
    .config/tmux/tmux.conf
    .config/blesh/init.sh
    .config/yazi/yazi.toml
    .local/bin/kitty-workspace
    .local/bin/yazi
    .local/share/blesh/ble.sh
    .themes/catppuccin-mocha-lavender-standard+default/index.theme
    .icons/Tela-circle-dark/index.theme
    .icons/Bibata-Modern-Classic/index.theme
    .local/share/gnome-shell/extensions/blur-my-shell@aunetx/metadata.json
)

for relative in "${required[@]}"; do
    [[ -e "$fake_home/$relative" ]] || {
        printf 'Missing after test restore: %s\n' "$relative" >&2
        exit 1
    }
done

if rg -n "__HOME__|$legacy_home" "$fake_home"; then
    printf 'An unexpanded home path remains in the test restore.\n' >&2
    exit 1
fi

printf 'File-layer restore test passed: %s\n' "$fake_home"
