# Terminal experience

This is the workstation terminal. It is **core**, not an optional look extra.

Open a new terminal after `./install.sh` and you should see:

1. **Fastfetch** (Ubuntu logo + compact system card)
2. A **two-line Starship** prompt with the current directory
3. **Zsh** with grey autosuggestions and green/red syntax colours

If you still see a default Ubuntu `$PS1`, the new files are not being used. Run `dotfiles-health`.

## Why it used to look stock

See [audit-terminal.md](audit-terminal.md). Short version: an older Oh My Zsh theme, a plain Starship line, and leftover neofetch were fighting each other, and Super+T often opened bash in GNOME Terminal. Fastfetch is now the only greeting.

## Stack (2026)

| Piece | Role |
|-------|------|
| **Zsh** | Interactive shell. Bash stays installed. |
| **Starship** | Only prompt. Two lines. Contextual git / language modules. |
| **Fastfetch** | Greeting once per local top-level interactive session |
| **Kitty** | Primary emulator (true colour, Nerd Font, padding) |
| **JetBrainsMono Nerd Font** | Icons. One font family. |
| **fzf** | CTRL-R history, CTRL-T files |
| **zoxide** | `z Projects` |
| **eza / bat / rg / fd** | Everyday file tools |
| **tmux** | `tm` / `ta` — never auto-started |
| **Yazi** | `y` if the Ubuntu archive has it |

Oh My Zsh is **not** sourced. An old `~/.oh-my-zsh` directory is left alone and unused.

## Greeting rules

Fastfetch runs when all of these are true:

- interactive shell
- not inside tmux
- not an SSH session
- `SHLVL` is 1 (not a nested shell)
- `UBUNTU_DOTFILES_NO_FETCH` is unset

Disable it:

```bash
echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local
```

## Prompt

```text
╭─ ~/Projects/ai/BotForge · main !
╰─❯
```

Home is `~`. Deep paths truncate. Git shows `!` modified, `+` staged, `?` untracked, `⇡`/`⇣` ahead/behind. Python, Node, Rust, Docker, and Kubernetes appear only inside matching projects. SSH adds `user@host`.

Palette: [theme/palette.md](../theme/palette.md).

## Verify on the laptop

```bash
preview-terminal
dotfiles-health
zsh-bench
echo "$SHELL"
echo "$0"
command -v zsh starship fastfetch kitty zoxide fzf
fc-list | grep -i 'JetBrainsMono Nerd'
```

## Manual steps

1. `cd ~/ubuntu-dotfiles && git pull && ./install.sh`
2. If login shell is still bash: `chsh -s "$(command -v zsh)"`
3. Log out and back in (font cache + default terminal)
4. Super+T should open **Kitty** running **zsh**
5. If icons are empty boxes, log out once more after `fc-cache -f`

Optional:

```bash
./install.sh --pentest
./install.sh --hyprland
```
