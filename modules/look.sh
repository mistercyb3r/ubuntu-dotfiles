#!/usr/bin/env bash
# Desktop look: Nerd Font cache, GNOME theme. Prompt/greeting live in modules/terminal.sh.

NERD_FONT_VERSION="${NERD_FONT_VERSION:-v3.4.0}"

configure_look() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look (--no-look)"
    return 0
  fi

  log_info "Applying desktop look (dark Yaru, Papirus, shared palette)"

  _look_install_nerd_font

  if [[ "${SKIP_GNOME:-0}" != "1" ]]; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/look.sh"
    gnome_apply_look
    gnome_apply_terminal_theme
  fi

  state_append_list "MODULES" "look"
  log_success "Desktop look applied. Super+T should open Kitty + zsh + Fastfetch."
}

_look_install_nerd_font() {
  local dest="${HOME}/.local/share/fonts/JetBrainsMonoNerd"
  if command_exists fc-list && fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
    log_skip "JetBrainsMono Nerd Font already installed"
    return 0
  fi
  if [[ -d "${dest}" ]] && ls "${dest}"/*.ttf >/dev/null 2>&1; then
    log_skip "Nerd Font files already in ${dest}"
    if ! is_dry_run; then
      fc-cache -f "${HOME}/.local/share/fonts" >/dev/null 2>&1 || true
    fi
    return 0
  fi

  log_info "Installing JetBrainsMono Nerd Font ${NERD_FONT_VERSION} (official nerd-fonts release)"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/JetBrainsMono.tar.xz"
  if is_dry_run; then
    log_dry "download ${url} -> ${dest}"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  if ! curl -fsSL "${url}" -o "${tmp}/JetBrainsMono.tar.xz"; then
    rm -rf "${tmp}"
    log_warn "Could not download Nerd Font. Terminal icons may be missing. Re-run later."
    return 0
  fi
  mkdir -p "${dest}"
  tar -xJf "${tmp}/JetBrainsMono.tar.xz" -C "${dest}"
  rm -rf "${tmp}"
  fc-cache -f "${HOME}/.local/share/fonts" >/dev/null 2>&1 || true
  log_success "Installed JetBrainsMono Nerd Font under ${dest}"
}
