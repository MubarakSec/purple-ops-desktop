# Purple Ops Desktop

A private, reproducible snapshot of MubarakSec's Ubuntu terminal-first desktop.
It restores the Kitty + tmux workbench, Bash inline suggestions, terminal
utilities, GNOME appearance and tiling settings, Purple Ops sounds, wallpaper,
fonts, extensions, boot splash, and login-screen identity.

The repository deliberately excludes passwords, tokens, SSH keys, browser
profiles, shell history, clipboard history, caches, and machine identifiers.
Neovim remains in its own private repository and is cloned during restoration.

## Rebuild

Target: Ubuntu 26.04 with GNOME 50.

```bash
git clone git@github.com:MubarakSec/purple-ops-desktop.git
cd purple-ops-desktop
./install.sh
```

The installer:

1. installs the required Ubuntu packages;
2. verifies every bundled archive;
3. backs up any managed files it is about to replace;
4. restores terminal configs, scripts, fonts, themes, extensions, and assets;
5. clones `MubarakSec/nvim-config`;
6. reapplies curated GNOME settings and hotkeys;
7. enables the wallpaper timer; and
8. installs Purple Ops Plymouth and GDM styling.

Log out and back in once when it finishes. Existing managed files are retained
under `~/.local/state/purple-ops-backups/<timestamp>`.

Useful options:

```bash
./install.sh --skip-packages
./install.sh --skip-system-theme
```

## Save later changes

After changing Kitty, tmux, Yazi, Bash, or GNOME:

```bash
cd ~/purple-ops-desktop
./scripts/capture.sh
./scripts/verify.sh
git add -A
git commit -m "chore: refresh desktop snapshot"
git push
```

The capture script uses a strict allowlist. It does not collect application
profiles, credentials, command history, or arbitrary files from the home
directory.

## What is preserved

- Kitty rendering, purple palette, Ctrl+Space, and Shift+Enter behavior
- tmux workspace, pane explorer, Yazi, Lazygit, btop, fuzzy file opening
- Bash + ble.sh inline suggestions and fzf integration
- Starship prompt and terminal aliases
- active Nerd Font, GTK theme, icon theme, cursor, wallpaper, and lock screen
- enabled GNOME extensions and their relevant settings
- dock, top bar, blur, notifications, tiling layouts, fonts, sound, and power
- Purple Ops system sounds, Plymouth boot splash, and GDM logo
- Ctrl+Alt+T preference for a fresh Kitty terminal

## Boundaries

This is a workstation configuration repository, not a personal-data backup.
Projects, documents, VM images, browser data, Bitwarden data, and SSH/GPG keys
must be backed up separately.

