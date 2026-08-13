#!/usr/bin/env bash
# Core visual terminal: Starship, Fastfetch, Kitty, tmux, Yazi, helpers.

configure_terminal() {
  log_info "Installing the workstation terminal configuration"

  mkdir -p "${XDG_CONFIG_HOME}/fastfetch" \
    "${XDG_CONFIG_HOME}/kitty" \
    "${XDG_CONFIG_HOME}/yazi"

  install_file "${REPO_ROOT}/terminal/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
  install_file "${REPO_ROOT}/terminal/tmux.conf" "${HOME}/.tmux.conf"
  install_file "${REPO_ROOT}/terminal/fastfetch.jsonc" "${XDG_CONFIG_HOME}/fastfetch/config.jsonc"
  install_file "${REPO_ROOT}/terminal/kitty.conf" "${XDG_CONFIG_HOME}/kitty/kitty.conf"
  install_file "${REPO_ROOT}/terminal/yazi/yazi.toml" "${XDG_CONFIG_HOME}/yazi/yazi.toml"
  install_file "${REPO_ROOT}/terminal/yazi/theme.toml" "${XDG_CONFIG_HOME}/yazi/theme.toml"

  _terminal_install_nerd_font
  _terminal_prefer_kitty
  _terminal_theme_gnome_fallback

  link_script "${REPO_ROOT}/scripts/system-info.sh" "system-info"
  link_script "${REPO_ROOT}/scripts/system-update.sh" "system-update"
  link_script "${REPO_ROOT}/scripts/cleanup.sh" "cleanup-system"
  link_script "${REPO_ROOT}/scripts/new-project.sh" "new-project"
  link_script "${REPO_ROOT}/scripts/server.sh" "server"
  link_script "${REPO_ROOT}/scripts/check-secrets.sh" "check-secrets"
  link_script "${REPO_ROOT}/scripts/preview-terminal.sh" "preview-terminal"
  link_script "${REPO_ROOT}/scripts/dotfiles-health.sh" "dotfiles-health"

  state_append_list "MODULES" "terminal"
}

_terminal_install_nerd_font() {
  # Same helper as look; Nerd Font is required for the prompt, not optional.
  if declare -F _look_install_nerd_font >/dev/null 2>&1; then
    _look_install_nerd_font
    return 0
  fi
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/modules/look.sh"
  _look_install_nerd_font
}

_terminal_prefer_kitty() {
  if ! command_exists kitty; then
    log_warn "Kitty is not installed; Super+T will keep using GNOME Terminal"
    return 0
  fi

  if command_exists gsettings; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    _gset org.gnome.desktop.default-applications.terminal exec "'kitty'"
    _gset org.gnome.desktop.default-applications.terminal exec-arg "''"
  fi

  if [[ -x /usr/bin/kitty ]] && command_exists update-alternatives; then
    if is_dry_run; then
      log_dry "update-alternatives --set x-terminal-emulator /usr/bin/kitty"
    else
      sudo_run update-alternatives --install /usr/bin/x-terminal-emulator \
        x-terminal-emulator /usr/bin/kitty 50 || true
      sudo_run update-alternatives --set x-terminal-emulator /usr/bin/kitty || true
    fi
  fi
  log_info "Default terminal set to Kitty (Super+T / Ctrl+Alt+T after logout)"
}

_terminal_theme_gnome_fallback() {
  # GNOME Terminal stays as a fallback and must use the same palette as Kitty.
  if ! command_exists gsettings; then
    return 0
  fi
  if ! gsettings list-schemas 2>/dev/null | grep -qx org.gnome.Terminal.ProfilesList; then
    return 0
  fi
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/settings.sh"
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/look.sh"
  gnome_apply_terminal_theme
}
