#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

pass() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1" >&2; failures=$((failures + 1)); }

printf 'Purple Ops repository checks\n'

for script in "$repo_root/install.sh" "$repo_root/scripts/"*.sh "$repo_root/home/.local/bin/"*; do
    if bash -n "$script"; then
        pass "shell syntax: ${script#"$repo_root"/}"
    else
        fail "shell syntax: ${script#"$repo_root"/}"
    fi
done

if (cd "$repo_root/archives" && sha256sum --check --quiet SHA256SUMS); then
    pass 'archive checksums'
else
    fail 'archive checksums'
fi

required=(
    home/.config/kitty/kitty.conf
    home/.config/tmux/tmux.conf
    home/.config/blesh/init.sh
    home/.config/yazi/yazi.toml
    home/.config/starship.toml
    assets/wallpapers/desktop.png
    assets/wallpapers/lockscreen.jpg
    dconf/shell-core.ini
    packages/apt.txt
)
for relative in "${required[@]}"; do
    [[ -e "$repo_root/$relative" ]] &&
        pass "present: $relative" ||
        fail "missing: $relative"
done

if rg -n --hidden \
    --glob '!archives/**' \
    --glob '!assets/fonts/**' \
    --glob '!assets/wallpapers/**' \
    --glob '!assets/PurpleOps/**' \
    --glob '!**/.git/**' \
    --glob '!scripts/verify.sh' \
    '/home/mobta|gho_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|password[[:space:]]*=' \
    "$repo_root"
then
    fail 'portable-path/credential scan'
else
    pass 'portable-path/credential scan'
fi

if (( failures )); then
    printf '\n%d check(s) failed.\n' "$failures" >&2
    exit 1
fi

printf '\nAll checks passed.\n'
