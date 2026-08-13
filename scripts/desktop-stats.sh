#!/usr/bin/env bash
# Start/stop the permanent Nordic desktop stats overlay (Conky).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF="${XDG_CONFIG_HOME:-${HOME}/.config}/conky/ubuntu-dotfiles.conf"
SRC="${ROOT}/desktop/conky.conf"

usage() {
  cat <<'EOF'
Usage: desktop-stats [start|stop|restart|status]
EOF
}

is_running() {
  pgrep -u "$(id -u)" -f 'conky .*ubuntu-dotfiles.conf' >/dev/null 2>&1
}

stop_stats() {
  pkill -u "$(id -u)" -f 'conky .*ubuntu-dotfiles.conf' 2>/dev/null || true
  sleep 0.2
}

start_stats() {
  if [[ ! -f "${CONF}" ]]; then
    mkdir -p "$(dirname "${CONF}")"
    cp "${SRC}" "${CONF}"
  fi
  if ! command -v conky >/dev/null 2>&1; then
    printf 'desktop-stats: conky is not installed. Re-run ./install.sh\n' >&2
    exit 1
  fi
  if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    printf 'desktop-stats: no graphical session; autostart will run at login\n' >&2
    exit 0
  fi
  stop_stats
  # GNOME Mutter has no layer-shell. XWayland + below/sticky is what stays on the desktop.
  conky -c "${CONF}" -d
  sleep 0.3
  if command -v wmctrl >/dev/null 2>&1; then
    wmctrl -x -r UbuntuDotfilesConky.UbuntuDotfilesConky -b add,below,sticky 2>/dev/null || true
  fi
  if is_running; then
    printf 'desktop-stats: running (top-right). stop with: desktop-stats stop\n'
  else
    printf 'desktop-stats: conky failed to start. Try: conky -c %s\n' "${CONF}" >&2
    exit 1
  fi
}

cmd="${1:-start}"
case "${cmd}" in
  start) start_stats ;;
  stop) stop_stats; printf 'desktop-stats: stopped\n' ;;
  restart) start_stats ;;
  status)
    if is_running; then
      printf 'desktop-stats: running\n'
    else
      printf 'desktop-stats: not running\n'
      exit 1
    fi
    ;;
  -h|--help) usage ;;
  *) usage; exit 1 ;;
esac
