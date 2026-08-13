#!/usr/bin/env bash
# Prove the workstation stack is actually in use. Run on the Ubuntu laptop.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
. "${ROOT}/lib/common.sh"

ok=0
warn=0
fail=0

status() {
  local level="$1"
  local name="$2"
  local detail="$3"
  case "${level}" in
    ok)
      printf '%s✓%s %s  %s%s%s\n' "${C_GREEN}" "${C_RESET}" "${name}" "${C_DIM}" "${detail}" "${C_RESET}"
      ok=$((ok + 1))
      ;;
    warn)
      printf '%s●%s %s  %s%s%s\n' "${C_YELLOW}" "${C_RESET}" "${name}" "${C_DIM}" "${detail}" "${C_RESET}"
      warn=$((warn + 1))
      ;;
    fail)
      printf '%s✗%s %s  %s%s%s\n' "${C_RED}" "${C_RESET}" "${name}" "${C_DIM}" "${detail}" "${C_RESET}"
      fail=$((fail + 1))
      ;;
  esac
}

have() { command -v "$1" >/dev/null 2>&1; }

printf '%s%sdotfiles-health%s\n' "${C_BOLD}" "${C_CYAN}" "${C_RESET}"
printf 'shell=%s  0=%s  TERM=%s  TERM_PROGRAM=%s\n' \
  "${SHELL:-unset}" "${0}" "${TERM:-unset}" "${TERM_PROGRAM:-unset}"

if have zsh; then
  status ok "Zsh" "$(command -v zsh)  $(zsh --version 2>/dev/null | awk '{print $2}')"
else
  status fail "Zsh" "not on PATH"
fi

login_shell="$(getent passwd "$(id -un)" 2>/dev/null | awk -F: '{print $7}' || true)"
if [[ "${login_shell}" == *zsh* ]]; then
  status ok "Login shell" "${login_shell}"
elif [[ -n "${login_shell}" ]]; then
  status warn "Login shell" "${login_shell} (run: chsh -s \$(command -v zsh))"
else
  status warn "Login shell" "could not read passwd (not Linux?)"
fi

if have starship; then
  cfg="${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml}"
  if [[ -f "${cfg}" ]] && grep -q '╭─' "${cfg}"; then
    status ok "Starship" "$(starship --version 2>/dev/null | head -n1)  two-line config loaded"
  elif [[ -f "${cfg}" ]]; then
    status warn "Starship" "installed but ${cfg} is not the two-line workstation prompt"
  else
    status warn "Starship" "binary present, config missing — re-run ./install.sh"
  fi
else
  status fail "Starship" "not on PATH"
fi

if have fastfetch; then
  ff_cfg="${XDG_CONFIG_HOME:-${HOME}/.config}/fastfetch/config.jsonc"
  [[ -f "${ff_cfg}" ]] || ff_cfg="${ROOT}/terminal/fastfetch.jsonc"
  if [[ ! -f "${ff_cfg}" ]]; then
    status fail "Fastfetch" "config missing — re-run ./install.sh"
  else
    _ff_probe=""
    set +e
    _ff_probe="$(fastfetch --config "${ff_cfg}" 2>&1)"
    _ff_rc=$?
    set -e
    if printf '%s\n' "${_ff_probe}" | grep -qi 'JsonConfig Error'; then
      status fail "Fastfetch" "invalid config ${ff_cfg} (JsonConfig Error)"
    elif [[ "${_ff_rc}" -ne 0 ]]; then
      status warn "Fastfetch" "config ${ff_cfg} ran with exit ${_ff_rc}"
    else
      status ok "Fastfetch" "$(command -v fastfetch)  config ${ff_cfg}"
    fi
    unset _ff_probe _ff_rc
  fi
else
  status fail "Fastfetch" "not on PATH — greeting will be empty. Re-run ./install.sh"
fi

if have neofetch; then
  status warn "Neofetch leftover" "$(command -v neofetch) is unused. Fastfetch is the greeting. Optional: sudo apt-get remove -y neofetch"
else
  status ok "Neofetch" "not installed (correct)"
fi

_rc_neofetch=""
for _rc in "${HOME}/.zshrc" "${HOME}/.bashrc" "${HOME}/.zprofile" "${HOME}/.profile"; do
  if [[ -f "${_rc}" ]] && grep -qE '(^|[[:space:]])neofetch([[:space:]]|$)' "${_rc}"; then
    _rc_neofetch="${_rc}"
    break
  fi
done
if [[ -n "${_rc_neofetch}" ]]; then
  status warn "Neofetch leftover" "${_rc_neofetch} still calls neofetch"
fi
unset _rc _rc_neofetch

if command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
  status ok "Nerd Font" "JetBrainsMono Nerd Font"
elif [[ -d "${HOME}/.local/share/fonts/JetBrainsMonoNerd" ]]; then
  status warn "Nerd Font" "files present; run fc-cache -f and log out"
else
  status fail "Nerd Font" "not installed — icons will be empty boxes"
fi

if have fzf; then
  status ok "fzf" "$(command -v fzf)"
else
  status fail "fzf" "not on PATH"
fi

if have zoxide; then
  status ok "zoxide" "$(command -v zoxide)"
else
  status warn "zoxide" "not on PATH (z jump will not work)"
fi

if have git; then
  status ok "Git" "$(git --version | awk '{print $3}')"
else
  status fail "Git" "not on PATH"
fi

if have docker; then
  status ok "Docker" "$(docker --version 2>/dev/null | head -n1)"
else
  status warn "Docker" "not installed (optional)"
fi

if have python3; then
  status ok "Python" "$(python3 --version 2>/dev/null)"
else
  status fail "Python" "python3 missing"
fi

if have node; then
  status ok "Node" "$(node --version 2>/dev/null)"
elif [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
  status warn "Node" "nvm present; open a new shell or run: nvm use --lts"
else
  status warn "Node" "not on PATH (skipped with --no-node?)"
fi

if have tailscale; then
  if tailscale status >/dev/null 2>&1; then
    status ok "Tailscale" "logged in"
  else
    status warn "Tailscale" "package present; run: sudo tailscale up"
  fi
else
  status warn "Tailscale" "not installed"
fi

if have kitty; then
  status ok "Kitty" "$(command -v kitty)"
else
  status fail "Kitty" "not on PATH — Super+T cannot open the workstation terminal"
fi

if have tmux; then
  status ok "tmux" "$(tmux -V 2>/dev/null)"
else
  status warn "tmux" "not on PATH"
fi

if have yazi; then
  status ok "Yazi" "$(command -v yazi)"
else
  status warn "Yazi" "not packaged on this Ubuntu (y alias inactive)"
fi

if [[ -f "${HOME}/.zshrc" ]] && grep -q 'ubuntu-dotfiles' "${HOME}/.zshrc"; then
  status ok "zshrc block" "${HOME}/.zshrc"
else
  status fail "zshrc block" "marked block missing — run ./install.sh"
fi

if [[ -f "${HOME}/.zshrc" ]] && grep -q 'oh-my-zsh.sh' "${HOME}/.zshrc"; then
  status warn "Oh My Zsh leftover" "~/.zshrc still sources oh-my-zsh.sh (comment it out; Starship is the only prompt)"
fi
if [[ -f "${HOME}/.zshrc" ]] && grep -qE 'ZSH_THEME="[^"]+"' "${HOME}/.zshrc"; then
  status warn "Oh My Zsh leftover" "ZSH_THEME is set in ~/.zshrc (competing prompt)"
fi
if [[ -f "${HOME}/.zshrc" ]] && grep -qE 'powerlevel10k|robbyrussell|p10k\.zsh' "${HOME}/.zshrc"; then
  status warn "Competing prompt" "~/.zshrc mentions Powerlevel10k or robbyrussell — Starship should be the only prompt"
fi
if [[ -f "${ROOT}/scripts/terminal-welcome.sh" ]] && grep -qE '(^|[[:space:]])neofetch([[:space:]]|$)' "${ROOT}/scripts/terminal-welcome.sh"; then
  status fail "Welcome script" "terminal-welcome.sh still invokes the legacy fetch tool"
elif [[ -f "${ROOT}/scripts/terminal-welcome.sh" ]] && grep -q 'fastfetch' "${ROOT}/scripts/terminal-welcome.sh"; then
  status ok "Welcome script" "uses Fastfetch"
else
  status fail "Welcome script" "terminal-welcome.sh does not call Fastfetch"
fi

default_term=""
if command -v gsettings >/dev/null 2>&1; then
  default_term="$(gsettings get org.gnome.desktop.default-applications.terminal exec 2>/dev/null || true)"
fi
if [[ "${default_term}" == *kitty* ]]; then
  status ok "Super+T terminal" "${default_term}"
elif [[ -n "${default_term}" ]]; then
  status warn "Super+T terminal" "${default_term} (expected kitty)"
else
  status warn "Super+T terminal" "gsettings unavailable here"
fi

if [[ -f "${ROOT}/scripts/theme-health.sh" ]]; then
  if bash "${ROOT}/scripts/theme-health.sh"; then
    status ok "Theme" "Kitty / Starship / tmux match theme/palette.env"
  else
    status fail "Theme" "palette mismatch — run theme-health"
  fi
fi

printf '\n%s%d ok%s  %s%d warn%s  %s%d fail%s\n' \
  "${C_GREEN}" "${ok}" "${C_RESET}" \
  "${C_YELLOW}" "${warn}" "${C_RESET}" \
  "${C_RED}" "${fail}" "${C_RESET}"

if [[ "${fail}" -gt 0 ]]; then
  printf '\nRe-run on Ubuntu:  cd ~/ubuntu-dotfiles && git pull && ./install.sh\n'
  exit 1
fi
exit 0
