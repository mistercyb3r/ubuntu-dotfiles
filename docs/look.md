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
| **Oh My Zsh** | Plugin framework (git, fzf, ghost text, syntax colours) |
| **Starship** | Two-line prompt: `in ~/folder on main` then `❯` |
| **neofetch** | Full system card when a terminal opens |
| **eza --icons** | Fancy `ls` |
| **zoxide** | `z project` jumps to frequent dirs |
| **Bottom dock** | Ubuntu's left side launcher becomes a centred macOS-style dock |
| **cmatrix / pipes** | Optional toys, not on startup |

Not installed on purpose:

- **Hyprland** — different desktop, worse battery/stability on this laptop
- **Powerlevel10k / heavy OMZ themes** — Starship is the prompt; OMZ is only for plugins
- **Blur my Shell** — pretty, but it stutters on Intel UHD 620
- Theme PPAs and random `curl \| sh` rices

## Everyday commands

```bash
# Super+T  →  Kitty (zsh + Oh My Zsh + neofetch)
fetch      # run neofetch again
matrix     # green rain (q to quit)
pipes      # colourful pipes (Ctrl-C to quit)
z name     # jump to a directory you use often
ll         # eza with icons
```

Turn the greeting off:

```bash
echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local
```

## Dock only

If the left side panel is still there, run this on the laptop (graphical session):

```bash
cd ~/ubuntu-dotfiles
git pull
bash gnome/dock.sh
```

That moves Ubuntu Dock to the **bottom** and stops it stretching into a full side bar. It **hides** when a window is fullscreen or sits over the dock, and comes back when you push the pointer to the bottom edge.

## After install

1. `git pull && ./install.sh`
2. Log out and back in (font + default terminal)
3. Open **Kitty** with Super+T
4. If icons look like boxes, the font cache needed a session restart — log out once more

GNOME Terminal is still themed as a fallback (Ctrl+Alt+T on some Ubuntu images).
