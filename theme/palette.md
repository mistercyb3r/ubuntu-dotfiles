# Workstation palette

One dark blue-black language for the whole machine. Inspired by Tokyo Night and Catppuccin, not a copy of either.

Aesthetic: premium modern Linux developer workstation. Dark, clean, readable. Not neon, not a 2010 hacker movie.

Source of truth for scripts: `theme/palette.env`

| Token | Hex | Use |
|-------|-----|-----|
| `UDF_BG` | `#0B0E14` | Kitty / tmux / Waybar / Yazi background |
| `UDF_FG` | `#D8DEE9` | Primary text |
| `UDF_CYAN` | `#7DCFFF` | Directory, prompt rails, Kitty cursor, accents |
| `UDF_BLUE` | `#7AA2F7` | Docker, Kubernetes, URLs |
| `UDF_PURPLE` | `#BB9AF7` | Username, Git branch, titles |
| `UDF_GREEN` | `#9ECE6A` | Success `❯`, valid commands, Node |
| `UDF_RED` | `#F7768E` | Failed `❯`, invalid commands, root |
| `UDF_YELLOW` | `#E0AF68` | Git dirty, duration, Python, warnings |
| `UDF_MUTED` | `#565F89` | Separators, suggestions, inactive chrome |
| `UDF_SELECTION` | `#1A2744` | Selection (subtle dark blue, not neon) |
| `UDF_CURSOR` | `#7DCFFF` | Caret |
| `UDF_SURFACE` | `#12161F` | Inactive tabs, tmux messages |
| `UDF_BORDER` | `#1C2230` | Inactive borders |
| `UDF_BRIGHT` | `#ECEFF4` | Bright white (ANSI 15) |

## Where each colour is used

| App | File |
|-----|------|
| Kitty | `terminal/kitty.conf` |
| Starship | `terminal/starship.toml` |
| tmux | `terminal/tmux.conf` |
| fzf | `terminal/fzf.env` (reads `palette.env`) |
| Yazi | `terminal/yazi/theme.toml` |
| Fastfetch | `terminal/fastfetch.jsonc` (ANSI keys → Kitty palette) |
| Zsh highlight / suggestions | `shell/plugins.zsh` (reads `palette.env`) |
| GNOME Terminal | `gnome/look.sh` |
| Hyprland | `hyprland/hyprland.conf` |
| Waybar | `hyprland/waybar/style.css` |

Verify: `theme-health` or `dotfiles-health`.
