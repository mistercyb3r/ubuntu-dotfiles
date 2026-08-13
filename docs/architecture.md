# Architecture

## Design goals

- Idempotent install and uninstall
- User config separate from system packages
- No secrets in git
- No hard-coded username or hostname
- Prefer Ubuntu archive packages
- Fail closed on critical errors
- Developable on Windows, runnable only on Ubuntu

## Layout

```text
ubuntu-dotfiles/
├── install.sh              Orchestrator (10 stages, CLI flags)
├── uninstall.sh            Reverses config this repo wrote
├── lib/                    Shared logging, backups, OS detection
├── bootstrap/              Minimum tools the installer itself needs
├── packages/               Software installation (apt, languages, optional)
├── modules/                Apply configuration (shell, git, ssh, gnome, …)
├── shell/                  Zsh files sourced from ~/.zshrc
├── git/                    Shared gitconfig (no identity)
├── terminal/               Starship, tmux, Fastfetch, Ptyxis, Yazi, fzf
├── theme/                  Nordic palette, GTK CSS, wallpaper
├── hyprland/               Optional session (./install.sh --hyprland)
├── gnome/                  gsettings, look theme, extension policy
├── ssh/                    Example client config (placeholders)
├── scripts/                User-facing commands linked into ~/.local/bin
├── config/                 Global gitignore, env example
├── templates/              new-project scaffolds
└── docs/
```

Optional installer flags (existing modules, not a rewrite): `--ai`, `--gaming`, `--languages`, `--virt`, `--pentest`, `--hyprland`.

## User vs system

| System (sudo) | User (no sudo) |
|---------------|----------------|
| apt packages | `~/.zshrc` marked block |
| Docker apt repo + engine | `~/.gitconfig` include.path |
| zram / fstrim.timer | `~/.config/starship.toml` |
| docker group membership | `~/.ssh/config` Include |
| Tailscale package | `~/Projects` |
| | nvm, pipx, uv |

## Idempotency

- Packages: skip if `dpkg` reports installed
- Files: skip if contents already match
- Shell/git: marked blocks / `include.path` are replaced in place, not duplicated
- Existing Docker: detected and left alone
- Existing SSH keys: never overwritten

## Backups

Before a file is changed, it is copied to:

```text
~/.local/share/ubuntu-dotfiles/backups/YYYYMMDD-HHMMSS/
```

The original path relative to `$HOME` is preserved inside that stamp directory.

## State

```text
~/.local/share/ubuntu-dotfiles/state
~/.local/share/ubuntu-dotfiles/repo-path
```

Used by helper scripts (to find the clone) and by uninstall.

## Dry-run

`DRY_RUN=1` makes `run` / `sudo_run` / file writers print the action and return. No packages, files, or groups are changed.

## Why not Oh My Zsh / random install scripts

Oh My Zsh slows startup and pulls a large plugin surface. Starship is a single binary.

Third-party `curl | sh` installers are avoided. Exceptions that remain official and pinned:

- nvm: `git clone` of a tagged release (`v0.40.6`)
- Docker / GitHub CLI / Tailscale: their **signed apt repositories**, not convenience scripts
- Starship: Ubuntu package, else official GitHub release tarball
