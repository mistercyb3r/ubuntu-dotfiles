# Current Linux research (2026-08)

Decisions for Ubuntu 26.04 / GNOME 50 on a Latitude 5400 (Intel UHD 620, 16 GB).

## GNOME extensions

| Extension | GNOME 50 | Decision |
|-----------|----------|----------|
| Ubuntu Dock (packaged dash-to-dock) | Yes, Ubuntu 26.04 | **Use.** Already shipped. Configured as a bottom dock. |
| AppIndicator | Yes, Ubuntu package | **Use.** Tray apps (Tailscale, Steam later). |
| Desktop Icons NG | Yes, Ubuntu package | Leave Ubuntu default. Not required for a dock workflow. |
| Blur my Shell 72 | Claims 50 | **Do not install.** Conflicts with Ubuntu Dock overview highlight. Extra GPU cost on UHD 620. |
| Dash to Dock from e.g.o | 105 supports 50 | Redundant with Ubuntu Dock. |
| Clipboard Indicator | — | Redundant. GNOME 50 has a built-in clipboard. |
| Vitals / dash-to-panel monitors | varies | **Skip.** Always-on sensors hurt battery. Use `stats` / `btop` when needed. |
| Conky | Desktop overlay | **Opt-in only.** Never autostart on GNOME Wayland — an XWayland overlay at login can freeze Mutter (no cursor). `desktop-stats start` for this session; `recover-desktop` from a TTY if the session hangs. |
| D2D Companion | 46–50 | Cosmetic dock motion. Skip. |

This repo does not install extensions from extensions.gnome.org.

## Icons and GTK

| Choice | Why |
|--------|-----|
| Papirus-Dark | Maintained, in Ubuntu archive, coherent MIME icons, Nordic-compatible. |
| papirus-folders | Recolour folders to `nordic` when the package exists. |
| Yaru cursor | Already on Ubuntu. No extra cursor pack. |
| Yaru-dark / Yaru-teal-dark | libadwaita-safe. Full custom GTK themes break GNOME 50 apps. |
| `theme/gtk-4.0.css` | Accent + surfaces only, from `palette.env`. |
| Ubuntu Sans 11 | Default Ubuntu UI font; best performance. Inter only if `fonts-inter` is packaged. |

## CLI tools

| Tool | Decision |
|------|----------|
| eza, bat, fd, ripgrep, fzf, zoxide, jq, yq, tldr, btop, duf | Keep / already installed. |
| lazygit, shfmt, ncdu | Add when packaged. |
| mtr-tiny, traceroute, whois, smartmontools | Small net/disk diagnostics in the optional apt list. |
| dust | Skip. Overlaps `duf` + `ncdu`. |
| procs, zellij | Skip. Overlap `btop` / tmux. |
| shellcheck | Already in core apt. |

## Languages and AI

| Topic | Decision |
|-------|----------|
| Python + uv, Node via nvm | Default full profile. Detect-and-skip if present. |
| Rust / Go / JDK | `./install.sh --languages` only. apt packages, not rustup/sdkman. |
| Ollama | `--ai` installs only if the archive has `ollama`. No `curl \| sh`. |
| CUDA | Never on Intel-only hardware. Detect via `lspci`. |
| Steam / Godot / Blender / Wine | `--gaming` prepares dirs only. Large apps are manual. |
| virt-manager | `./install.sh --virt` only. |

## Performance

Keep animations. Do not disable mitigations. No TLP (conflicts with power-profiles-daemon). No preload. No always-on shell monitors. No Blur my Shell.
