#!/usr/bin/env bash
# Run when a terminal opens. Safe to source from bash or zsh.
# Must use `return` (not exit) so sourcing cannot kill the shell.

if [ -n "${UBUNTU_DOTFILES_NO_FETCH:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
if [ -n "${TMUX:-}" ]; then
  return 0 2>/dev/null || exit 0
fi
if [ -n "${UBUNTU_DOTFILES_FETCH_DONE:-}" ]; then
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

if command -v neofetch >/dev/null 2>&1; then
  neofetch
elif command -v fastfetch >/dev/null 2>&1; then
  fastfetch
else
  printf '\n  neofetch is not installed. Run: sudo apt-get install -y neofetch\n\n'
fi
