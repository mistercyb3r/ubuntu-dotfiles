# Installed software

Every major tool this workstation installs, and why. If a package is missing from a given Ubuntu release, the installer skips it instead of adding a random PPA.

## Core CLI

| Package / binary | Why |
|------------------|-----|
| `build-essential` | gcc/make for native Python/Node addons and compiling tools |
| `git` | Version control |
| `gh` | GitHub CLI (PRs, clones, auth). Apt archive, else official GitHub apt repo |
| `openssh-client` | SSH and GitHub SSH. **Client only** |
| `curl` / `wget` | Downloads |
| `unzip` / `zip` / `tar` | Archives |
| `ca-certificates` / `gnupg` | TLS and signed apt repos |
| `jq` | JSON in the terminal (APIs, compose, gh) |
| `tree` | Directory maps |
| `ripgrep` (`rg`) | Fast project search; works well with Cursor/AI workflows |
| `fd-find` (`fd`) | Fast file find; Ubuntu names the binary `fdfind` |
| `fzf` | Fuzzy finder for history, files, branches |
| `bat` | Syntax-highlighted pager; Ubuntu names it `batcat` |
| `eza` | Readable `ls` with git status, **if** the archive has it |
| `htop` | Process view |
| `btop` | Resource dashboard (skipped if unavailable) |
| `tmux` | Persistent sessions over SSH |
| `zsh` | Interactive shell (bash remains installed) |
| `starship` | Fast prompt: directory, git, python, node |
| `shellcheck` | Lint the installer itself on the laptop |
| `git-lfs` | Large files in some GitHub projects |
| `xclip` / `wl-clipboard` | Copy SSH public keys from the terminal |
| `plocate` | `locate` database, if available |

## Python

| Tool | Why |
|------|-----|
| `python3` + `venv` + `pip` + `dev` | System interpreter and headers |
| `pipx` | Isolated **user** installers for CLI tools |
| `uv` | Fast project/package manager, installed **via pipx**, never `sudo pip` |

## Node.js

| Tool | Why |
|------|-----|
| `nvm` | Version manager; project `.nvmrc` can pin LTS |
| Node.js LTS + `npm` | Default runtime. No global npm packages |

## Docker (full profile)

| Tool | Why |
|------|-----|
| `docker-ce` + CLI | Official Engine from Docker's apt repo |
| `containerd.io` | Runtime |
| `docker-compose-plugin` | `docker compose` |
| `docker-buildx-plugin` | Buildx |

If `docker` is already on `PATH`, it is **not** replaced.

## Desktop / laptop

| Tool | Why |
|------|-----|
| `fonts-jetbrains-mono` | Default programming font |
| `fonts-firacode` | Optional ligature font, if packaged |
| `gnome-tweaks` | Full profile only; settings UI. No extension dump |
| `papirus-icon-theme` | Dark icon set for the look profile |
| `kitty` | GPU terminal; Super+T default |
| `zsh-autosuggestions` | Grey ghost-text; right-arrow accepts |
| `zsh-syntax-highlighting` | Green valid / red invalid commands |
| `zoxide` | Fast directory jumper (`z`) |
| `fastfetch` | Supported system-info greeting. Ubuntu 26.04 universe package, else official GitHub .deb |
| `git-delta` | Readable git diffs when packaged |
| `yazi` | Terminal file manager (`y`) when packaged |
| `duf` / `yq` / `tealdeer` | Disks, YAML, short man pages — skipped if missing |
| `cmatrix` | Optional rain effect (`matrix`) |
| JetBrainsMono Nerd Font | Official nerd-fonts release; icons in prompt and `eza` |
| `gnome-shell-extension-manager` | UI to add one extension yourself; none are enabled by us |
| `power-profiles-daemon` | `balanced` / `performance` without TLP |
| `systemd-zram-generator` or `zram-tools` | Compressed RAM swap on 16 GB |
| `fstrim.timer` | Weekly SSD TRIM |

## Optional

| Tool | Why |
|------|-----|
| `tailscale` | Mesh VPN to the home server. **Not logged in automatically** |

## Deliberately not installed

| Thing | Reason |
|-------|--------|
| Oh My Zsh | Not sourced. Starship is the only prompt. |
| neofetch | Legacy. Never installed. Fastfetch is the only greeting. |
| TLP | Conflicts with `power-profiles-daemon` |
| `preload` | Extra daemon, mixed benefit |
| NVIDIA drivers | This machine is Intel iGPU |
| GNOME extension packs | Break across GNOME upgrades |
| `openssh-server` | This laptop is an SSH **client** |
| Random PPAs | Stability |
| Global `sudo pip` / global npm CLIs | Pollute the system |
| Gaming stacks / extra browsers | Out of scope |
| Cursor itself | Install from Cursor's official package on the laptop |

## Why each CLI quality-of-life tool

- **fzf** — jump to files and history without slow GUIs
- **ripgrep** — search large trees; AI tools and humans both use it
- **fd** — same, for filenames
- **bat** — read source in the terminal
- **eza** — `ls` that shows git state; skipped rather than adding a third-party repo
- **jq** — inspect API responses
- **btop/htop** — see what is eating the 16 GB
- **tmux** — keep a compile or SSH session alive when the lid closes (with care)
