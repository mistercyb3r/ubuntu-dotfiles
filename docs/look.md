# Desktop look

The **terminal stack is always installed**. `--no-look` only skips GNOME wallpaper, Yaru purple, and Papirus.

```bash
cd ~/ubuntu-dotfiles
git pull
./install.sh
```

## What you get

| Piece | Role |
|-------|------|
| **Ptyxis** | Default terminal, Nordic palette, 92% opacity |
| **Papirus-Dark** | Application / folder / MIME icons |
| **Yaru-dark + teal accent** | GNOME 50 / libadwaita-safe theme |
| **Nordic wallpaper** | `theme/wallpapers/nordic-polar.svg` |
| **JetBrainsMono Nerd Font** | Icons in prompt and `eza` |
| **Starship** | Two-line prompt (see [terminal.md](terminal.md)) |
| **Fastfetch** | Supported system-info greeting |
| **Yaru dark + purple accent** | Ubuntu theme, no extra PPAs |
| **Papirus-Dark** | Icons |
| **Bottom dock** | Centred, hides over windows |
| **cmatrix / pipes** | Toys, not on startup |

Not installed on purpose:

- **Hyprland** unless you pass `--hyprland`
- **Oh My Zsh themes**
- **Blur my Shell** (stutters on Intel UHD 620; conflicts with Ubuntu Dock)
- Theme PPAs and `curl | sh` rices
- Extra GNOME extensions from extensions.gnome.org

Research notes: [research.md](research.md).

## Everyday commands

```bash
# Super+T  →  Ptyxis (zsh + Fastfetch + two-line prompt)
# Desktop  →  dark Yaru, Papirus, polar wallpaper
fetch              # Fastfetch again
preview-terminal   # show the intended look
dotfiles-health    # green / yellow / red proof
z name             # jump to a frequent directory
ll                 # eza with icons
y                  # Yazi (if packaged)
tm                 # tmux session "main"
```

Turn the greeting off:

```bash
echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local
```

## Dock only

```bash
cd ~/ubuntu-dotfiles
git pull
bash gnome/dock.sh
```

## After install

1. `git pull && ./install.sh`
2. Log out and back in
3. Super+T → Ptyxis
4. Empty-box icons → log out once more after the font cache updates
