#!/usr/bin/env bash
# Apply the optional desktop + terminal look.

configure_look() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look (--no-look)"
    return 0
  fi

  log_info "Applying a dark, slightly modded developer look"

  install_file "${REPO_ROOT}/terminal/fastfetch.jsonc" \
    "${XDG_CONFIG_HOME}/fastfetch/config.jsonc"
  install_file "${REPO_ROOT}/terminal/neofetch.conf" \
    "${XDG_CONFIG_HOME}/neofetch/config.conf"

  if [[ "${SKIP_GNOME:-0}" != "1" ]]; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/look.sh"
    gnome_apply_look
    gnome_apply_terminal_theme
  fi

  state_append_list "MODULES" "look"
  log_success "Look applied. Open a new terminal and log out/in once for GNOME theme changes."
  log_info "Disable the fetch greeting with: echo 'export UBUNTU_DOTFILES_NO_FETCH=1' >> ~/.zshrc.local"
}
