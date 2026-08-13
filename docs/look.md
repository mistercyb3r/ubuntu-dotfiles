# Desktop and terminal look

This is the stack people usually rice Ubuntu with in 2025–2026, kept light enough for a Latitude 5400.

```bash
cd ~/ubuntu-dotfiles
git pull
./install.sh
```

Skip it: `./install.sh --no-look`

## What you get

| Piece | Why it is the current default online |
|-------|--------------------------------------|
| **Kitty** | GPU terminal, transparency, cursor trail |
| **JetBrainsMono Nerd Font** | Icons in the prompt and `eza` |
| **Catppuccin Mocha** | The palette almost every rice uses |
| **Starship** | Fast prompt (instead of Oh My Zsh / Powerlevel10k) |
| **zsh-autosuggestions** | Grey ghost text as you type |
| **zsh-syntax-highlighting** | Green valid commands, red typos |
| **fastfetch** | Replaced neofetch for most people |
| **eza --icons** | Fancy `ls` |
| **zoxide** | `z project` jumps to frequent dirs |
| **Papirus + purple Yaru** | Dark desktop without a fragile GTK theme zip |
| **cmatrix / pipes** | Optional toys, not on startup |

Not installed on purpose:

- **Hyprland** — different desktop, worse battery/stability on this laptop
- **Oh My Zsh** — slow; Starship + two plugins is the modern equivalent
- **Blur my Shell** — pretty, but it stutters on Intel UHD 620
- Theme PPAs and random `curl \| sh` rices

## Everyday commands

```bash
# Super+T  →  Kitty
fetch      # fastfetch / neofetch
matrix     # green rain (q to quit)
pipes      # colourful pipes (Ctrl-C to quit)
z name     # jump to a directory you use often
ll         # eza with icons
```

Turn the greeting off:

```bash
echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local
```

## After install

1. `git pull && ./install.sh`
2. Log out and back in (font + default terminal)
3. Open **Kitty** with Super+T
4. If icons look like boxes, the font cache needed a session restart — log out once more

GNOME Terminal is still themed as a fallback (Ctrl+Alt+T on some Ubuntu images).
