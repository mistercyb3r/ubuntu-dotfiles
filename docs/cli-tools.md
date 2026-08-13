# CLI tool decisions

Installed only when the Ubuntu archive has the package (or Starship's official GitHub binary). No random PPAs.

## Installed (real everyday value)

| Tool | Why |
|------|-----|
| **eza** | Readable `ls` with git + icons (`ll` `la` `lt`) |
| **bat** | Syntax-highlighted file view (`cat` alias is display-only) |
| **fd** | Fast file find; Ubuntu binary is `fdfind`, wrapped as `fd` |
| **ripgrep** | Project search for Cursor / AI / code |
| **fzf** | CTRL-R history, CTRL-T files, branch pickers |
| **zoxide** | `z BotForge` after a few visits |
| **jq** | JSON for APIs, compose, `gh` |
| **yq** | YAML for compose / Caddy / k8s (skipped if not packaged) |
| **btop** | Resource view on 16 GB; `htop` remains as fallback |
| **fastfetch** | Supported system-info greeting. Ubuntu 26.04: `universe` package. Older: official GitHub .deb. |
| **tealdeer / tldr** | Short examples (`tldr tar`) |
| **yazi** | Terminal file manager (`y`). Skipped if not packaged. |
| **duf** | Readable `df` for disks |
| **git-delta** | Readable diffs; Git pager when present |
| **tmux** | Persistent sessions; not auto-started |
| **Kitty** | One GPU terminal. Not five emulators. |

## Not installed on purpose

| Tool | Why skip |
|------|----------|
| **neofetch** | Legacy. Not installed. `dotfiles-health` warns if a leftover copy remains. |
| **dust** | Overlaps `duf` + `eza`. Extra binary for little gain. |
| **procs** | Overlaps `btop` / `htop`. |
| **zellij** | tmux is already configured and familiar over SSH. |
| **Oh My Zsh themes** | Fight Starship and look like 2018 Ubuntu tutorials. |
| **Powerlevel10k** | Heavy; Starship is the prompt. |
| **Five terminal emulators** | Kitty + GNOME Terminal fallback only. |

## Homelab helpers (no secrets)

| Command | Behaviour |
|---------|-----------|
| `ssh-home` | `ssh homeserver` (or `$HOME_SSH_HOST`) from your SSH config |
| `tailscale-status` | `tailscale status` |
| `docker-status` | `docker ps` table |
| `ports` | `ss -tulpn` |
| `sysinfo` | `system-info` |

Private IPs and usernames stay in `~/.ssh/config.d/*.conf`, never in this repo.

## Optional modules

```bash
./install.sh --pentest     # nmap, wireshark, ffuf, hashcat, ...
./install.sh --hyprland    # second session; GNOME stays default
```
