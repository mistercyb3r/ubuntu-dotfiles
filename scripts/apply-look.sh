#!/usr/bin/env bash
# Force-apply Nordic desktop + Ptyxis on a logged-in Ubuntu GNOME session.
# Run this in a desktop terminal after git pull. Then close every terminal.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "${ROOT}/lib/common.sh"
# shellcheck disable=SC1091
. "${ROOT}/lib/os.sh"
# shellcheck disable=SC1091
. "${ROOT}/modules/look.sh"
# shellcheck disable=SC1091
. "${ROOT}/modules/terminal.sh"

if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  die "No graphical session. Run this on the Ubuntu desktop, not a plain SSH login."
fi

printf 'repo=%s\ncommit=%s\n' "${ROOT}" "$(git -C "${ROOT}" log -1 --oneline 2>/dev/null || echo unknown)"

SKIP_LOOK=0
SKIP_GNOME=0
configure_look
_terminal_theme_ptyxis
_terminal_prefer_ptyxis

printf '\n--- after apply ---\n'
if command_exists gsettings; then
  printf 'wallpaper %s\n' "$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null || true)"
  printf 'accent    %s\n' "$(gsettings get org.gnome.desktop.interface accent-color 2>/dev/null || true)"
  printf 'icons     %s\n' "$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)"
  printf 'terminal  %s\n' "$(gsettings get org.gnome.desktop.default-applications.terminal exec 2>/dev/null || true)"
fi
if command_exists dconf; then
  uuid="$(dconf read /org/gnome/Ptyxis/default-profile-uuid 2>/dev/null | tr -d "'" || true)"
  printf 'ptyxis    uuid=%s palette=%s opacity=%s\n' \
    "${uuid}" \
    "$(dconf read /org/gnome/Ptyxis/Profiles/${uuid}/palette 2>/dev/null || echo unset)" \
    "$(dconf read /org/gnome/Ptyxis/Profiles/${uuid}/opacity 2>/dev/null || echo unset)"
fi
printf 'palette   %s\n' "${XDG_DATA_HOME:-${HOME}/.local/share}/org.gnome.Ptyxis/palettes/Workstation.palette"

log_success "Done. Close EVERY Ptyxis/terminal window, then log out and back in."
