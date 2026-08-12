# Troubleshooting

## Installer refuses to run on Windows

That is intentional. Clone or copy the repo to the Latitude 5400 and run it there.

## `sudo` password / installer stops

The installer must run as a normal user with sudo. Do not run `sudo ./install.sh`.

## GNOME settings did nothing

They require a graphical session (`DISPLAY` or `WAYLAND_DISPLAY`). Log into the Ubuntu desktop and re-run:

```bash
./install.sh --no-docker --no-node --no-python
```

or:

```bash
bash gnome/settings.sh
```

## Starship not found after install

Open a **new** terminal. If still missing:

```bash
command -v starship
ls /usr/local/bin/starship
```

Ubuntu 22.04 may have used the GitHub binary into `/usr/local/bin`. Ensure `~/.local/bin` and `/usr/local/bin` are on `PATH`.

## `bat` / `fd` command not found

Ubuntu names them `batcat` and `fdfind`. The installer links `~/.local/bin/bat` and `fd`. Open a new shell.

## Node / `nvm` not found

nvm is lazy-loaded. Run `loadnvm` or `nvm --version`. If `~/.nvm` is missing, re-run `./install.sh` without `--no-node`.

## Docker: permission denied on `/var/run/docker.sock`

You are not in the `docker` group yet, or you have not logged out since being added.

```bash
groups
# log out of GNOME entirely, then back in
docker ps
```

This installer will not reboot the machine. Using `sudo docker` also works.

## Docker already installed, installer skipped it

Expected. Existing Engine is preserved. Remove it yourself only if you intend to replace `docker.io` with `docker-ce`.

## GitHub SSH: `Permission denied (publickey)`

```bash
sshpubkey
ssh -T git@github.com
ls -l ~/.ssh/id_ed25519.pub
```

Confirm the **public** key is added to GitHub. Private keys must never be uploaded.

## `https://github.com` clones fail after enabling insteadOf

URL rewriting is **commented out** in `git/gitconfig` until SSH works. If you enabled it yourself, comment it again or use `git clone git@github.com:org/repo.git`.

## Zsh is not the login shell

```bash
chsh -s "$(command -v zsh)"
```

Then log out. Bash is still installed.

## Slow shell startup

```bash
zsh-startup
```

nvm is lazy-loaded on purpose. Extra content in `~/.zshrc` **outside** the marked block is the usual cause. Oh My Zsh is not used.

## Lid close kills tmux/SSH

GNOME is set not to suspend on AC. On battery it will suspend. Use Tailscale + tmux on the **server**, not as a reason to disable suspend on a laptop.

## zram / TRIM

```bash
swapon --show
systemctl status fstrim.timer
```

## Uninstall left packages installed

By design. `./uninstall.sh --purge-packages` removes a small set (zsh, starship, …) but never Docker or git.

## Restoring a backup

```bash
ls ~/.local/share/ubuntu-dotfiles/backups/
cp -a ~/.local/share/ubuntu-dotfiles/backups/<STAMP>/.<file> ~/.<file>
```

Paths inside the stamp directory mirror `$HOME`.
