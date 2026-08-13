#!/usr/bin/env bash
# Verify Ptyxis, Starship and tmux still use theme/palette.env.
# Safe on Windows (Git Bash) and Ubuntu. Does not change the system.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PALETTE="${ROOT}/theme/palette.env"

if [[ ! -f "${PALETTE}" ]]; then
  printf 'theme-health: missing %s\n' "${PALETTE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
. "${PALETTE}"

ok=0
warn=0
fail=0

has_hex() {
  local file="$1"
  local hex="$2"
  [[ -f "${file}" ]] && grep -qi -- "${hex}" "${file}"
}

check() {
  local file="$1"
  local hex="$2"
  local label="$3"
  if has_hex "${file}" "${hex}"; then
    printf '✓ %s  %s\n' "${label}" "${hex}"
    ok=$((ok + 1))
  else
    printf '✗ %s  missing %s in %s\n' "${label}" "${hex}" "${file}" >&2
    fail=$((fail + 1))
  fi
}

legacy() {
  local file="$1"
  local hex="$2"
  local why="$3"
  if [[ -f "${file}" ]] && has_hex "${file}" "${hex}"; then
    printf '● leftover %s in %s (%s)\n' "${hex}" "${file}" "${why}" >&2
    warn=$((warn + 1))
  fi
}

PTYXIS="${ROOT}/terminal/ptyxis/Workstation.palette"
STARSHIP="${ROOT}/terminal/starship.toml"
TMUX="${ROOT}/terminal/tmux.conf"
GTK4="${ROOT}/theme/gtk-4.0.css"
WALL="${ROOT}/theme/wallpapers/nordic-polar.png"
[[ -f "${WALL}" ]] || WALL="${ROOT}/theme/wallpapers/nordic-polar.svg"
KITTY="${ROOT}/terminal/kitty.conf"

printf 'theme-health  palette=%s\n' "${PALETTE}"

if [[ -f "${KITTY}" ]]; then
  printf '✗ stale Kitty config still present: %s\n' "${KITTY}" >&2
  fail=$((fail + 1))
else
  printf '✓ Kitty config removed\n'
  ok=$((ok + 1))
fi

check "${PTYXIS}" "${UDF_BG}" "Ptyxis background"
check "${PTYXIS}" "${UDF_FG}" "Ptyxis foreground"
check "${PTYXIS}" "${UDF_CYAN}" "Ptyxis cyan"
check "${PTYXIS}" "${UDF_BLUE}" "Ptyxis blue"
check "${PTYXIS}" "${UDF_PURPLE}" "Ptyxis purple"
check "${PTYXIS}" "${UDF_GREEN}" "Ptyxis green"
check "${PTYXIS}" "${UDF_RED}" "Ptyxis red"
check "${PTYXIS}" "${UDF_YELLOW}" "Ptyxis yellow"

if [[ -n "${UDF_OPACITY:-}" ]]; then
  printf '✓ Ptyxis opacity token  %s\n' "${UDF_OPACITY}"
  ok=$((ok + 1))
else
  printf '✗ UDF_OPACITY missing from %s\n' "${PALETTE}" >&2
  fail=$((fail + 1))
fi

check "${STARSHIP}" "${UDF_CYAN}" "Starship directory/rails"
check "${STARSHIP}" "${UDF_PURPLE}" "Starship git/user"
check "${STARSHIP}" "${UDF_GREEN}" "Starship success"
check "${STARSHIP}" "${UDF_RED}" "Starship error"

check "${TMUX}" "${UDF_BG}" "tmux background"
check "${TMUX}" "${UDF_CYAN}" "tmux accent"
check "${TMUX}" "${UDF_FG}" "tmux foreground"

check "${GTK4}" "${UDF_CYAN}" "GTK4 frost accent"
check "${GTK4}" "${UDF_BG}" "GTK4 window background"
check "${WALL}" "${UDF_POLAR_DARKEST:-#1F232B}" "wallpaper polar darkest"
check "${WALL}" "${UDF_FROST_CYAN:-#88C0D0}" "wallpaper frost"

legacy "${PTYXIS}" "#0B0E14" "old Tokyo Night background"
legacy "${STARSHIP}" "#7DCFFF" "old Tokyo Night cyan"
legacy "${STARSHIP}" "#c0caf5" "old Tokyo Night foreground"
legacy "${TMUX}" "#0B0E14" "old Tokyo Night background"
legacy "${TMUX}" "#7DCFFF" "old Tokyo Night cyan"
legacy "${STARSHIP}" "#ff9e64" "off-palette orange"

printf '\n%d ok  %d warn  %d fail\n' "${ok}" "${warn}" "${fail}"
if [[ "${fail}" -gt 0 ]]; then
  exit 1
fi
exit 0
