# Purple Ops

Your prefix is `Ctrl+Space`. Press it, release it, then press the action key.
`Ctrl+b` is the backup prefix if an application or remote machine captures
`Ctrl+Space`.

For the workbench letters (`y`, `g`, `m`, and `f`), keeping `Ctrl` held also
works.

## Start here

Type `terminal-help` in any prompt to open this guide again. The same guide is
available inside tmux with `Ctrl+Space`, then `?`.

The everyday tools are:

| What you want | In tmux | At a prompt |
|---|---|---|
| Browse and manage files | `Ctrl+Space`, then `y` | `y` or `files` |
| Find a file by its name or contents of its path | `Ctrl+Space`, then `f` | `ff` |
| Browse files beside the shell | `Ctrl+Space`, then `e` | — |
| Work with the current Git repository | `Ctrl+Space`, then `g` | `lg` |
| See CPU, memory, disks, and network | `Ctrl+Space`, then `m` | `bt` |

## Workspace

| Key | Action |
|---|---|
| `c` | New tmux window in the current directory |
| `w` | Choose a window |
| `s` | Choose a session |
| `Tab` | Return to the previous window |
| `d` | Detach and leave everything running |
| `r` | Reload the tmux configuration |

## Panes

| Key | Action |
|---|---|
| `\|` | Split left/right |
| `-` | Split top/bottom |
| `h j k l` | Move between panes |
| `Shift+H` | Resize the active pane toward the left |
| `Shift+J` | Resize the active pane downward |
| `Shift+K` | Resize the active pane upward |
| `Shift+L` | Resize the active pane toward the right |
| `z` | Zoom or restore the active pane |
| `x` | Close a pane |
| `X` | Close a window |

After `Ctrl+Space`, you can repeat `Shift+H/J/K/L` without pressing the
prefix again.

## Terminal size

These Kitty shortcuts work directly; they do not use the tmux prefix.

| Key | Action |
|---|---|
| `Ctrl+Shift++` | Increase the font size |
| `Ctrl+Shift+-` | Decrease the font size |
| `Ctrl+Shift+0` | Reset the font to its configured size |
| `Alt+F8` | Resize the entire Kitty window |

## Workbench

| Key | Action |
|---|---|
| `y` | Yazi terminal file manager |
| `g` | Lazygit |
| `m` | btop system and network monitor |
| `f` | Find a file and open it in Neovim |
| `e` | Toggle the left file explorer |
| `?` | Show this guide |

## Left explorer

`Ctrl+Space`, then `e` opens Yazi in a left sidebar beside your shell.

| Key | Action |
|---|---|
| `j` / `k` or arrows | Move through files |
| `l` or `Right` | Enter the selected directory |
| `h` or `Left` | Go to the parent directory |
| `Enter` | Open the selected item |
| `q` | Close the sidebar and move the shell to its current directory |

Press `Ctrl+Space`, then `e` again to close the sidebar without changing the
shell directory.

## Finding files with fzf

`Ctrl+Space`, then `f` opens a searchable list of files under the current
directory. Type any part of a filename to narrow the list. Use `Ctrl+j` and
`Ctrl+k` (or the arrow keys) to move, `Enter` to open the selected file in
Neovim, and `Esc` to cancel. The pane on the right previews the selected file.

Type `ff` for the same picker without using tmux.

## Managing files in Yazi

Start Yazi with `y`, `files`, or `Ctrl+Space`, then `y`. It opens in the
current directory; when you press `q`, your shell follows the directory you
were viewing.

| Key | Action |
|---|---|
| `j` / `k` or arrows | Move through files |
| `Enter` | Open a file or enter a directory |
| `h` / `l` | Parent directory / selected directory |
| `Space` | Select or unselect a file |
| `y` / `x` / `p` | Copy / cut / paste selected files |
| `d` | Send the selected file to the trash |
| `/` | Find files by name |
| `~` | Show Yazi's complete key reference |
| `q` | Quit and return to the shell |

## Shell

- `y` browses files and changes the shell directory when you exit.
- `z name` jumps to a frequently used directory.
- `zi` interactively chooses a directory.
- `ll` shows a detailed Git-aware listing.
- `lt` shows a two-level directory tree.
- `b file` previews a file with syntax highlighting.
- `ports` and `listening` show local network listeners.

The status bar turns amber while tmux is waiting for an action after the prefix.
