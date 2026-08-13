#!/usr/bin/env bash
# Demonstrate the workstation terminal stack. Run this on the Ubuntu laptop.
# Safe on Windows: prints what can be verified and what must be checked on Ubuntu.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "${ROOT}/lib/common.sh"

C_CYAN="${C_CYAN:-\033[36m}"
C_PURPLE=$'\033[35m'
C_GREEN="${C_GREEN:-\033[32m}"
C_RED="${C_RED:-\033[31m}"
C_YELLOW="${C_YELLOW:-\033[33m}"
C_DIM="${C_DIM:-\033[2m}"
C_BOLD="${C_BOLD:-\033[1m}"
C_RESET="${C_RESET:-\033[0m}"

section() {
  printf '\n%s%s── %s ──%s\n' "${C_BOLD}" "${C_CYAN}" "$1" "${C_RESET}"
}

preview_prompt() {
  local dir="$1"
  local extra="$2"
  local ok="${3:-1}"
  local glyph
  if [[ "${ok}" == "1" ]]; then
    glyph="${C_GREEN}❯${C_RESET}"
  else
    glyph="${C_RED}❯${C_RESET}"
  fi
  printf '%s╭─%s %s%s%s %s\n' "${C_CYAN}" "${C_RESET}" "${C_BOLD}${C_CYAN}" "${dir}" "${C_RESET}" "${extra}"
  printf '%s╰─%s%s\n' "${C_CYAN}" "${C_RESET}" "${glyph}"
}

printf '%s%sWorkstation terminal preview%s\n' "${C_BOLD}" "${C_CYAN}" "${C_RESET}"
printf '%sThis is what Super+T should look like after ./install.sh on Ubuntu.%s\n' "${C_DIM}" "${C_RESET}"

section "1. Fastfetch"
if command -v fastfetch >/dev/null 2>&1; then
  cfg="${XDG_CONFIG_HOME:-${HOME}/.config}/fastfetch/config.jsonc"
  [[ -f "${cfg}" ]] || cfg="${ROOT}/terminal/fastfetch.jsonc"
  _ff_out=""
  _ff_err=0
  set +e
  _ff_out="$(UBUNTU_DOTFILES_NO_FETCH=1 fastfetch --config "${cfg}" 2>&1)"
  _ff_err=$?
  set -e
  if printf '%s\n' "${_ff_out}" | grep -qi 'JsonConfig Error'; then
    printf '%sFastfetch rejected the config:%s %s\n' "${C_RED}" "${C_RESET}" "${cfg}"
    printf '%s\n' "${_ff_out}"
    printf '%sFix terminal/fastfetch.jsonc for this Fastfetch version, then re-run ./install.sh%s\n' "${C_YELLOW}" "${C_RESET}"
  elif [[ "${_ff_err}" -ne 0 ]]; then
    printf '%sfastfetch --config failed (exit %s). Not falling back to a default theme.%s\n' "${C_RED}" "${_ff_err}" "${C_RESET}"
    printf '%s\n' "${_ff_out}"
  else
    printf '%s\n' "${_ff_out}"
  fi
  unset _ff_out _ff_err
else
  printf '%sfastfetch is not on this machine (expected on Windows).%s\n' "${C_YELLOW}" "${C_RESET}"
  printf 'On Ubuntu it prints a compact Ubuntu logo + host / CPU / RAM / Tailscale.\n'
fi

section "2. Two-line Starship prompt (directory + git)"
preview_prompt "~/Projects/ubuntu-dotfiles" "${C_DIM}·${C_RESET} ${C_PURPLE}main${C_RESET} ${C_YELLOW}!${C_RESET}"

section "3. Git status symbols"
printf '  %sclean%s     (branch only)\n' "${C_GREEN}" "${C_RESET}"
printf '  %s!%s         modified   %s+%s staged   %s?%s untracked\n' \
  "${C_YELLOW}" "${C_RESET}" "${C_GREEN}" "${C_RESET}" "${C_CYAN}" "${C_RESET}"
printf '  %s⇡n%s        ahead      %s⇣n%s behind\n' "${C_YELLOW}" "${C_RESET}" "${C_YELLOW}" "${C_RESET}"

section "4. Python context (only inside a Python project)"
preview_prompt "~/Projects/python/api" "${C_DIM}·${C_RESET} ${C_PURPLE}main${C_RESET} ${C_DIM}·${C_RESET} ${C_YELLOW}py 3.12${C_RESET}"

section "5. Node context (only inside a Node project)"
preview_prompt "~/Projects/web/app" "${C_DIM}·${C_RESET} ${C_PURPLE}develop${C_RESET} ${C_DIM}·${C_RESET} ${C_GREEN}node 22${C_RESET}"

section "6. Docker context (compose / Dockerfile present)"
preview_prompt "~/Projects/homelab/caddy" "${C_DIM}·${C_RESET} ${C_PURPLE}main${C_RESET} ${C_DIM}·${C_RESET} ${C_BLUE}docker${C_RESET}"

section "7. SSH prompt (remote host only)"
preview_prompt "~/caddy" "${C_DIM}·${C_RESET} ${C_PURPLE}mistercyber${C_RESET}${C_CYAN}@homeserver${C_RESET}"

section "8. Failed command"
preview_prompt "~/Projects/security/lab" "${C_DIM}·${C_RESET} ${C_PURPLE}main${C_RESET}" 0

section "9. Live Starship render"
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml"
  [[ -f "${STARSHIP_CONFIG}" ]] || export STARSHIP_CONFIG="${ROOT}/terminal/starship.toml"
  printf '%sSTARSHIP_CONFIG=%s%s\n' "${C_DIM}" "${STARSHIP_CONFIG}" "${C_RESET}"
  if command -v starship >/dev/null 2>&1; then
    printf '%s' "$(starship prompt 2>/dev/null)" || printf '%s(starship prompt unavailable; open a zsh terminal)%s\n' "${C_DIM}" "${C_RESET}"
    printf '\n'
  fi
else
  printf '%sstarship is not on PATH here. After install, run: echo | starship prompt%s\n' "${C_YELLOW}" "${C_RESET}"
fi

section "10. What to type next on Ubuntu"
cat <<EOF
  dotfiles-health
  zsh-bench
  echo "\$SHELL  \$0"
  command -v zsh starship fastfetch ptyxis zoxide fzf
  fc-list | grep -i 'JetBrainsMono Nerd'
  Super+T  →  Ptyxis should open zsh with Fastfetch then the two-line prompt
EOF
