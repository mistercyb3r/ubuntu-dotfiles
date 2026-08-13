# Nordic design system

Source of truth: `theme/palette.env`. Do not invent hex values in app configs.

## Tokens

| Token | Hex | Role |
|-------|-----|------|
| `UDF_POLAR_DARKEST` | `#1F232B` | Wallpaper depth, deepest chrome |
| `UDF_POLAR_DARKER` | `#242933` | Elevated surfaces |
| `UDF_POLAR_DARK` / `UDF_BG` | `#2E3440` | Terminal / window background |
| `UDF_SNOW` / `UDF_FG` | `#D8DEE9` | Primary text |
| `UDF_SNOW_BRIGHT` / `UDF_BRIGHT` | `#ECEFF4` | Bright text, ANSI 15 |
| `UDF_MUTED` | `#4C566A` | Terminal separators, comments |
| `UDF_MUTED_UI` | `#7B88A1` | Desktop secondary labels |
| `UDF_FROST_BLUE` / `UDF_BLUE` | `#81A1C1` | Accent, Docker, k8s |
| `UDF_FROST_CYAN` / `UDF_CYAN` | `#88C0D0` | Directory, prompt rails, cursor |
| `UDF_FROST_LIGHT` | `#8FBCBB` | Soft highlight |
| `UDF_AURORA_GREEN` / `UDF_GREEN` | `#A3BE8C` | Success |
| `UDF_AURORA_YELLOW` / `UDF_YELLOW` | `#EBCB8B` | Warning, git dirty |
| `UDF_AURORA_RED` / `UDF_RED` | `#BF616A` | Error |
| `UDF_AURORA_PURPLE` / `UDF_PURPLE` | `#B48EAD` | Username, git branch |
| `UDF_OPACITY` | `0.92` | Ptyxis window opacity |

`UDF_MUTED` stays Polar Night `#4C566A` for terminal contrast. `UDF_MUTED_UI` is the lighter desktop grey.

## Where it is applied

| Surface | File |
|---------|------|
| Ptyxis | `terminal/ptyxis/Workstation.palette` |
| Starship | `terminal/starship.toml` |
| Fastfetch | ANSI cyan / magenta → Ptyxis Nord |
| tmux / fzf / Yazi | `terminal/` |
| GTK 4 / 3 | `theme/gtk-4.0.css`, `theme/gtk-3.0.css` |
| Wallpaper | `theme/wallpapers/nordic-polar.svg` |
| GNOME accent | teal (closest shipped frost) |
| Waybar | `hyprland/waybar/style.css` |

## Ptyxis mapping

| palette.env | Ptyxis `.palette` |
|-------------|-------------------|
| `UDF_BG` | `Background` |
| `UDF_FG` | `Foreground` |
| `UDF_RED` | `Color1` / `Color9` |
| `UDF_GREEN` | `Color2` / `Color10` |
| `UDF_YELLOW` | `Color3` / `Color11` |
| `UDF_BLUE` | `Color4` / `Color12` |
| `UDF_PURPLE` | `Color5` / `Color13` |
| `UDF_CYAN` | `Color6` / `Color14` |
| `UDF_OPACITY` | profile `opacity` |

Verify: `theme-health` or `dotfiles-health`.
