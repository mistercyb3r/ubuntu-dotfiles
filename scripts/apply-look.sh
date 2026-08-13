#!/usr/bin/env bash
# Apply Nordic desktop + Ptyxis on a logged-in Ubuntu GNOME session.
# Safe to re-run. Does not install packages.
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
  die "No graphical session. Run this in a terminal on the Ubuntu desktop, not over a plain SSH login."
fi

SKIP_LOOK=0
SKIP_GNOME=0
configure_look
_terminal_theme_ptyxis
_terminal_prefer_ptyxis

log_success "Look applied. Close every terminal, then log out and back in."
log_info "If Super+T still opens the old app, the dock shortcut is stale until logout."
