#!/usr/bin/env bash
# Safe from a TTY (Ctrl+Alt+F3) when GNOME is frozen or the cursor is gone.
set -euo pipefail

rm -f "${XDG_CONFIG_HOME:-${HOME}/.config}/autostart/ubuntu-dotfiles-conky.desktop"
pkill -u "$(id -u)" -f 'conky .*ubuntu-dotfiles.conf' 2>/dev/null || true
pkill -u "$(id -u)" -x conky 2>/dev/null || true

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface cursor-theme 'Yaru' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
fi

printf 'Conky autostart removed and Conky killed.\n'
printf 'Restart the login screen:\n'
printf '  sudo systemctl restart gdm\n'
