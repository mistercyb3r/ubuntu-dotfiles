#!/usr/bin/env bash
# Popular 2025–2026 Ubuntu look: Kitty, Nerd Font, zsh effects, fastfetch.
# Ubuntu archive packages plus one official Nerd Fonts GitHub release.

LOOK_PACKAGES=(
  kitty
  zsh-autosuggestions
  zsh-syntax-highlighting
  papirus-icon-theme
  yaru-theme-gtk
  yaru-theme-icon
  gnome-tweaks
  gnome-shell-extension-manager
  neofetch
  cmatrix
  unzip
  xz-utils
  fontconfig
)

LOOK_OPTIONAL=(
  fastfetch
  zoxide
)

install_look_packages() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look packages (--no-look)"
    return 0
  fi

  log_info "Installing the current popular Ubuntu look stack"
  apt_install_missing "${LOOK_PACKAGES[@]}"
  apt_install_missing "${LOOK_OPTIONAL[@]}"
  state_append_list "MODULES" "look-packages"
}
