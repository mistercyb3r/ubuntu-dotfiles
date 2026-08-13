# Desktop and terminal look

The full installer applies a dark, slightly modded developer theme. It is optional.

```bash
./install.sh            # includes the look
./install.sh --no-look  # keep the plainer developer defaults
```

Re-apply only the look after a GNOME login:

```bash
bash gnome/look.sh
```

## What you get

| Area | Change |
|------|--------|
| GNOME | Dark mode, purple Yaru accent, Papirus-Dark icons |
| Dock | Floating, 65% opacity, auto-hide |
| Wallpaper | Stock Ubuntu dark wallpaper (no random downloads) |
| Terminal | Catppuccin Mocha colours, 12% transparency, JetBrains Mono |
| Prompt | Starship with the same palette |
| Greeting | `fastfetch` if installed, otherwise `neofetch` |
| Effect | `cmatrix` (run `matrix`) |

No unofficial GNOME extensions are installed. Blur-my-Shell and similar break on GNOME upgrades. Use **Extension Manager** yourself if you want one extra extension.

## Terminal greeting

Shown once on an interactive top-level shell. Not shown inside tmux panes or nested shells.

Turn it off:

```bash
echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local
```

Run it anytime:

```bash
fetch
neofetch
fastfetch
```

## Matrix effect

```bash
matrix
# or: cmatrix -u 8
```

`q` quits. This is a toy; it is not started automatically.

## Why not a full “rice”

- No theme PPAs
- No curl-piped ricing scripts
- No dozen GNOME extensions
- Transparency stays low so text stays readable on the Latitude panel
- Fetch is skipped in subshells so startup stays fast
