#!/usr/bin/env bash
# Desktop look: Nerd Font cache, GNOME theme. Prompt/greeting live in modules/terminal.sh.

NERD_FONT_VERSION="${NERD_FONT_VERSION:-v3.4.0}"

configure_look() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look (--no-look)"
    return 0
  fi

  log_info "Applying desktop look (Nordic Yaru, Papirus, shared palette)"

  _look_install_nerd_font
  _look_install_gtk_css
  _look_recolor_papirus_folders
  _look_install_conky

  if [[ "${SKIP_GNOME:-0}" != "1" ]]; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/look.sh"
    gnome_apply_look
    gnome_apply_terminal_theme
  fi

  state_append_list "MODULES" "look"
  log_success "Desktop look applied. Super+T should open Ptyxis + zsh + Fastfetch."
}

_look_install_gtk_css() {
  local gtk4="${XDG_CONFIG_HOME}/gtk-4.0"
  local gtk3="${XDG_CONFIG_HOME}/gtk-3.0"
  mkdir -p "${gtk4}" "${gtk3}"
  install_file "${REPO_ROOT}/theme/gtk-4.0.css" "${gtk4}/gtk.css"
  install_file "${REPO_ROOT}/theme/gtk-3.0.css" "${gtk3}/gtk.css"
}

_look_recolor_papirus_folders() {
  if ! command_exists papirus-folders; then
    return 0
  fi
  if is_dry_run; then
    log_dry "papirus-folders -C nordic --theme Papirus-Dark"
    return 0
  fi
  if papirus-folders -l --theme Papirus-Dark 2>/dev/null | grep -qi nordic; then
    papirus-folders -C nordic --theme Papirus-Dark >/dev/null 2>&1 || true
    log_success "Papirus folder colour: nordic"
  elif papirus-folders -l --theme Papirus-Dark 2>/dev/null | grep -qi grey; then
    papirus-folders -C grey --theme Papirus-Dark >/dev/null 2>&1 || true
    log_success "Papirus folder colour: grey"
  fi
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

_look_install_conky() {
  mkdir -p "${XDG_CONFIG_HOME}/conky"
  install_file "${REPO_ROOT}/desktop/conky.conf" "${XDG_CONFIG_HOME}/conky/ubuntu-dotfiles.conf"
  link_script "${REPO_ROOT}/scripts/desktop-stats.sh" "desktop-stats"
  link_script "${REPO_ROOT}/scripts/recover-desktop.sh" "recover-desktop"

  # Never autostart Conky on GNOME. An XWayland overlay at login can freeze
  # Mutter (no cursor, session hung). Remove any copy left by an older install.
  local autostart="${XDG_CONFIG_HOME}/autostart/ubuntu-dotfiles-conky.desktop"
  if [[ -f "${autostart}" ]]; then
    if is_dry_run; then
      log_dry "rm ${autostart}"
    else
      rm -f "${autostart}"
      log_success "Removed Conky autostart (it can freeze GNOME Wayland)"
    fi
  fi

  if command_exists pkill; then
    pkill -u "$(id -u)" -f 'conky .*ubuntu-dotfiles.conf' 2>/dev/null || true
  fi

  log_info "Desktop stats are opt-in only: desktop-stats start"
}
