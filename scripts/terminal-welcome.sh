#!/usr/bin/env bash
# Fastfetch once per new local interactive top-level terminal.
# Must use `return` (not exit) so sourcing cannot kill the shell.
#
# Skip: non-interactive, tmux, nested shells, SSH, explicit opt-out.

if [ -n "${UBUNTU_DOTFILES_NO_FETCH:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
if [ -n "${TMUX:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
if [ -n "${UBUNTU_DOTFILES_FETCH_DONE:-}" ]; then
  return 0 2>/dev/null || exit 0
fi

# Nested interactive shells (zsh inside zsh, or bash then zsh without exec).
if [ "${SHLVL:-1}" -gt 1 ]; then
  return 0 2>/dev/null || exit 0
fi

# Only interactive terminals
case $- in
  *i*) ;;
  *)
    if [ -z "${PS1:-}" ]; then
      return 0 2>/dev/null || exit 0
    fi
    ;;
esac

UBUNTU_DOTFILES_FETCH_DONE=1
export UBUNTU_DOTFILES_FETCH_DONE

_ff_cfg="${XDG_CONFIG_HOME:-${HOME}/.config}/fastfetch/config.jsonc"
if [ ! -f "${_ff_cfg}" ] && [ -n "${UBUNTU_DOTFILES_ROOT:-}" ]; then
  _ff_cfg="${UBUNTU_DOTFILES_ROOT}/terminal/fastfetch.jsonc"
fi

if command -v fastfetch >/dev/null 2>&1; then
  if [ -f "${_ff_cfg}" ]; then
    fastfetch --config "${_ff_cfg}"
  else
    fastfetch
  fi
else
  printf '\n  Fastfetch is not installed. On Ubuntu run: ./install.sh\n\n'
fi
unset _ff_cfg
