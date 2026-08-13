# Ubuntu Latitude 5400 developer workstation

Reproducible Ubuntu configuration for a **Dell Latitude 5400** used as a software-development laptop: Git, GitHub, Cursor, Docker, SSH, Python, Node.js, and remote administration over Tailscale.

**Repository:** https://github.com/mistercyb3r/ubuntu-dotfiles

This repository is **safe to clone on Windows** for editing. The installer **refuses to run on Windows**. Run it only on the Ubuntu machine.

## What this project does

`./install.sh` installs a focused command-line environment, applies conservative desktop and laptop settings, and drops helper scripts on `PATH`. It is:

- Idempotent (safe to re-run)
- Non-destructive toward personal files
- Explicit about anything that needs a human decision (Git identity, GitHub SSH, Tailscale login, docker group)

It does **not** turn the laptop into a public SSH server, store secrets, or apply aggressive kernel tweaks.

## Target hardware

| Item | Value |
|------|--------|
| Model | Dell Latitude 5400 |
| CPU | Intel |
| Graphics | Intel integrated (UHD 620-class) |
| RAM | 16 GB |
| Role | Development, AI-assisted coding, homelab admin |
| Not | A gaming machine |

Priorities: stability, responsiveness, battery life, developer productivity. No extra background daemons “for performance”.

## Supported Ubuntu versions

| Version | Status |
|---------|--------|
| Ubuntu 24.04 LTS | Primary target |
| Ubuntu 22.04 LTS | Supported |
| Other Ubuntu (24.10+) | Warns, continues if you confirm |
| Debian | Warns, continues if you confirm |
| Windows / MSYS / Cygwin | **Refused** |
| WSL | Warns (GNOME/power/zram will not apply correctly) |

## What gets installed

Core tools from Ubuntu repositories where possible:

Zsh, Starship, git, GitHub CLI (`gh`), OpenSSH **client**, build-essential, fzf, ripgrep, fd, bat, eza (if the archive has it), jq, tree, btop, htop, tmux, curl, wget, unzip, Python 3, pipx, uv, nvm + Node.js LTS, JetBrains Mono.

Optional (full profile): Docker Engine, Tailscale package, and the current popular look (Kitty, Catppuccin, Nerd Font, fastfetch, zsh effects).

See [docs/installed-software.md](docs/installed-software.md) for why each tool exists.

## What gets configured

| Area | Behaviour |
|------|-----------|
| Shell | Zsh + Starship; marked block in `~/.zshrc` (existing content kept) |
| Git | Shared defaults via `include.path`; **no** name/email in the repo |
| Terminal | Kitty (Catppuccin, cursor trail), Starship, tmux |
| SSH | Client defaults + example host file; **no** `sshd` |
| GNOME | Dark purple Yaru, Papirus icons, floating dock — **no extra extensions** |
| Look | Nerd Font, fastfetch, ghost-text, syntax colours, `matrix` / `pipes`. [docs/look.md](docs/look.md) |
| Projects | `~/Projects/{personal,ai,web,python,homelab,experiments}` |
| Performance | zram, SSD TRIM, `power-profiles-daemon` balanced |
| Backups | Timestamped copies under `~/.local/share/ubuntu-dotfiles/backups/` |

## How to install

On the **Latitude 5400** (fresh Ubuntu), as your normal user — not root:

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/mistercyb3r/ubuntu-dotfiles.git ~/ubuntu-dotfiles
cd ~/ubuntu-dotfiles
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh --dry-run
./install.sh
```

Preview without changing anything:

```bash
./install.sh --dry-run
```

Useful options:

```text
--full          default; includes Docker, GNOME, Node, optional extras
--minimal       packages + shell + git + terminal + projects
--no-gnome      skip desktop settings
--no-docker     skip Docker
--no-node       skip nvm / Node.js
--no-python     skip pipx / uv (apt python3 is still installed)
--no-look       skip themed desktop, terminal colours, and neofetch
--dry-run       print actions only
--yes           assume yes for prompts (still will not log into Tailscale)
```

Installer stages:

```text
[1/10] Checking system
[2/10] Installing packages
[3/10] Configuring shell
[4/10] Configuring Git
[5/10] Configuring terminal
[6/10] Configuring GNOME
[7/10] Configuring development tools
[8/10] Configuring project directories
[9/10] Running health checks
[10/10] Complete
```

Re-running `./install.sh` is expected after you pull updates.

## How to update

```bash
cd ~/ubuntu-dotfiles
git pull
./install.sh
system-update
```

`system-update` upgrades apt (and snap/pipx if present). It does **not** run `autoremove`. Use `cleanup-system` for a preview-first cleanup.

## How to uninstall

```bash
cd ~/ubuntu-dotfiles
./uninstall.sh
```

This removes the marked shell blocks, linked helper commands, and config this repo wrote. It never deletes `~/Projects`, Git repos, SSH keys, or your Git identity. Package removal is opt-in: `./uninstall.sh --purge-packages`.

## How to configure Git

Identity is **not** in this repository.

```bash
setup-git-identity
```

Or:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Verify:

```bash
git config --global --list | grep ^user
```

## How to configure GitHub SSH

1. Installer can generate `~/.ssh/id_ed25519` (or run `ssh-keygen -t ed25519`).
2. Print / copy the public key: `sshpubkey`
3. GitHub → Settings → SSH and GPG keys → New SSH key
4. Test: `ssh -T git@github.com`

Full walkthrough: [docs/github-ssh.md](docs/github-ssh.md).

## How to configure Tailscale

The installer may install the Tailscale **package**. It will **never** run `tailscale up` or use an auth key.

```bash
sudo tailscale up
tailscale status
```

Then put the MagicDNS name or Tailscale IP in `~/.ssh/config.d/10-homeserver.conf`. See [docs/tailscale.md](docs/tailscale.md).

## How to use the developer tools

| Command | Purpose |
|---------|---------|
| `system-info` | OS, CPU, RAM, disk, battery, IPs, Docker, toolchain |
| `system-update` | apt / snap / pipx updates |
| `cleanup-system` | preview unused apt packages; `--apply` to remove them |
| `new-project python foo` | scaffold under `~/Projects` |
| `server list` / `server ssh homeserver` | SSH to configured hosts |
| `check-secrets` | crude pre-commit secret scan |
| `setup-git-identity` | set `user.name` / `user.email` |
| `fetch` | fastfetch / neofetch greeting |
| `matrix` | cmatrix rain (`q` to quit) |
| `pipes` | colourful pipes (`Ctrl-C` to quit) |
| `z <dir>` | jump to a frequent directory (zoxide) |

Python: [docs/python.md](docs/python.md). Node: [docs/nodejs.md](docs/nodejs.md). Docker: [docs/docker.md](docs/docker.md).

Shell aliases are in `shell/aliases.sh`. `rm`, `mv`, and `cp` are **not** aliased.

## How to connect to the home server

1. Join Tailscale on both machines.
2. Copy `~/.ssh/config.d/homelab.conf.example` to `~/.ssh/config.d/10-homeserver.conf`.
3. Replace `<TAILSCALE_IP_OR_MAGICDNS_NAME>` and `<USERNAME>`.
4. `server ssh homeserver` or `ssh homeserver`.

Do **not** forward port 22 from your router to this laptop or to the home server.

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).

Quick checks:

```bash
system-info
./install.sh --dry-run
zsh-startup
```

## Security considerations

- No passwords, tokens, or private keys belong in this repo.
- `.env`, keys, and credential filenames are gitignored globally.
- SSH is configured as a **client**. `openssh-server` is not installed or enabled.
- Docker group membership is root-equivalent; you are asked before it is granted.
- Firewall rules are not changed.
- CPU vulnerability mitigations are not disabled.
- `check-secrets` plus a GitHub Action catch obvious accidents; they are not perfect.

Details: [docs/security.md](docs/security.md).

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Hardware notes

See [docs/latitude-5400.md](docs/latitude-5400.md).
