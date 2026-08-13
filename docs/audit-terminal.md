# Terminal audit (why it still looked like stock Ubuntu)

This was written by inspecting the repository, not by running the installer on Windows.

## What Ubuntu was actually using

| Expected | What often happened |
|----------|---------------------|
| Kitty + Nerd Font + Starship two-line prompt | Super+T or Ctrl+Alt+T still opened **GNOME Terminal + bash** |
| Fastfetch greeting | older installs preferred the legacy fetch tool (often missing) or nothing |
| Starship | `ZSH_THEME=robbyrussell` fallback = classic Oh My Zsh, looks like a tutorial from 2018 |
| JetBrainsMono Nerd Font | Installed under `~/.local/share/fonts` but the open terminal still used **Ubuntu Mono / JetBrains Mono without icons** |
| `~/.config/starship.toml` | Also `STARSHIP_CONFIG` in the repo — two copies, easy to drift |
| Oh My Zsh | Sourced in full. Empty/default theme **overrides the “premium” look** if Starship is late or missing |

## Duplicate / conflicting systems

1. **Oh My Zsh theme + Starship** — two prompt engines. If Starship is not on PATH, you get `robbyrussell` (default-looking).
2. **Two fetch tools** — greeting preferred the legacy tool (frequently not installed) instead of Fastfetch.
3. **Greeting sourced twice** — marked block in `~/.zshrc` and again in `shell/zshrc`.
4. **Look module was optional** — core `configure_terminal` installed a bland Starship; the visual stack lived behind `--look`.
5. **No Hyprland files** — nothing to audit; not installed.
6. **No verification command** — nothing proved the laptop was using the new files.

## Fix (this redesign)

- One prompt: **Starship only**. Oh My Zsh is not sourced for appearance.
- One greeting: **Fastfetch**, local interactive top-level shells only (not tmux, not SSH).
- Terminal visuals are **core**, not an optional look extra.
- Kitty is the Super+T terminal and is forced to `/usr/bin/zsh` + Nerd Font.
- `preview-terminal` and `dotfiles-health` prove the stack on the laptop.
