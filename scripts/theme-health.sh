#!/usr/bin/env bash
# Verify Kitty, Starship and tmux still use theme/palette.env.
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

norm() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

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
  if has_hex "${file}" "${hex}"; then
    printf '● leftover %s in %s (%s)\n' "${hex}" "${file}" "${why}" >&2
    warn=$((warn + 1))
  fi
}

KITTY="${ROOT}/terminal/kitty.conf"
STARSHIP="${ROOT}/terminal/starship.toml"
TMUX="${ROOT}/terminal/tmux.conf"

printf 'theme-health  palette=%s\n' "${PALETTE}"

check "${KITTY}" "${UDF_BG}" "Kitty background"
check "${KITTY}" "${UDF_FG}" "Kitty foreground"
check "${KITTY}" "${UDF_CYAN}" "Kitty accent"
check "${KITTY}" "${UDF_SELECTION}" "Kitty selection"
check "${KITTY}" "${UDF_CURSOR}" "Kitty cursor"

check "${STARSHIP}" "${UDF_CYAN}" "Starship directory/rails"
check "${STARSHIP}" "${UDF_PURPLE}" "Starship git/user"
check "${STARSHIP}" "${UDF_GREEN}" "Starship success"
check "${STARSHIP}" "${UDF_RED}" "Starship error"

check "${TMUX}" "${UDF_BG}" "tmux background"
check "${TMUX}" "${UDF_CYAN}" "tmux accent"
check "${TMUX}" "${UDF_FG}" "tmux foreground"

legacy "${KITTY}" "#c0caf5" "old Tokyo Night foreground"
legacy "${STARSHIP}" "#c0caf5" "old Tokyo Night foreground"
legacy "${TMUX}" "#c0caf5" "old Tokyo Night foreground"
legacy "${KITTY}" "#1e1e2e" "Catppuccin Mocha"
legacy "${KITTY}" "#cdd6f4" "Catppuccin Mocha"
legacy "${STARSHIP}" "#ff9e64" "off-palette orange"
legacy "${KITTY}" "cursor_trail" "motion effect"

printf '\n%d ok  %d warn  %d fail\n' "${ok}" "${warn}" "${fail}"
if [[ "${fail}" -gt 0 ]]; then
  exit 1
fi
exit 0
