# Purple Ops interactive Bash line editor

# Match the terminal's Catppuccin Mocha palette and keep suggestions subtle.
ble-import contrib/scheme/catppuccin_mocha
ble-face -s auto_complete 'fg=#5f5875,italic'

# Prefer useful history suggestions and avoid noisy ambiguous guesses.
bleopt complete_auto_complete=1
bleopt complete_auto_delay=140
bleopt complete_auto_complete_opts='syntax-suppress-ambiguous'
bleopt prompt_eol_mark=''
bleopt exec_exit_mark=''

# Load fzf through ble.sh's compatibility layer. This preserves Ctrl+R,
# Ctrl+T, and Alt+C without competing with the line editor.
ble-import -d integration/fzf-completion
ble-import -d integration/fzf-key-bindings
