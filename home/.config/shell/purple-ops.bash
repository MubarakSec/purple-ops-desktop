# Terminal-native navigation and sensible defaults
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less -R"
export MANPAGER="sh -c 'col -bx | bat --language=man --plain'"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="
  --height=70%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt=' SEARCH  '
  --pointer='◆'
  --marker='●'
  --color=bg+:#251a3d,bg:#0b0812,spinner:#c099ff,hl:#ff5c8a
  --color=fg:#b5a8d5,header:#61e2ff,info:#786e91,pointer:#a277ff
  --color=marker:#6ee7b7,fg+:#e8e3f3,prompt:#c099ff,hl+:#ff5c8a
"

if [[ -n "${BASH_VERSION-}" ]]; then
    eval "$(zoxide init bash)"
    if [[ ! ${BLE_VERSION-} ]]; then
        eval "$(fzf --bash)"
    fi
fi

# Arabic-friendly terminal (VTE BiDi). Kitty/tmux cannot reorder mixed
# Arabic + English text; Ptyxis handles it correctly.
arabic-term() {
    ptyxis --new-window -T "عربي" -d "$PWD" &>/dev/null &
}

function y() {
    local tmp cwd
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first --git'
alias la='eza -a --icons=auto --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
alias b='bat --paging=auto --style=numbers,changes,header'
alias lg='lazygit'
alias bt='btop'
alias vim='nvim'
alias music='cmus'
alias ports='ss -tulpn'
alias listening='ss -lntup'
alias public-ip='curl -fsS https://ifconfig.me; printf "\n"'
alias ..='cd ..'
alias ...='cd ../..'

keys() {
    cat << 'EOF' | bat --paging=never --language=markdown --plain
# 🟣 Purple Ops Desktop Shortcuts

## Window Management (1-Letter Mnemonics)
  Super + Q        Quit / Close active window
  Super + F        Fullscreen / Toggle maximize
  Super + T        Tile / Auto-tile all windows into grid
  Super + C        Center active floating window
  Super + Y        Pin window always on top (Sticky)

## Snapping (Arrow Snapping)
  Super + ← / →    Snap Left / Right Half
  Then Super + ↑   Push to Top Corner (Top-Left / Top-Right)
  Then Super + ↓   Push to Bottom Corner (Bottom-Left / Bottom-Right)
  Super + ↑ / ↓    Maximize / Restore window size

## System & Tools
  Super + K        Launch Kitty Terminal
  Super + V        Clipboard History Manager
  Super + P        Toggle Top Bar Autohide
  Super + /        Show GUI Shortcuts HUD
  music            Launch cmus terminal music player
EOF
}

