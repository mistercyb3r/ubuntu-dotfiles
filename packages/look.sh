#!/usr/bin/env bash
# Desktop look packages only (theme, icons, toys). Terminal stack is in packages/terminal.sh.

LOOK_PACKAGES=(
  papirus-icon-theme
  papirus-folders
  yaru-theme-gtk
  yaru-theme-icon
  fonts-inter
  gnome-tweaks
  gnome-shell-extension-manager
  wmctrl
  cmatrix
  unzip
  xz-utils
  fontconfig
)

install_look_packages() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look packages (--no-look)"
    return 0
  fi

  log_info "Installing desktop look packages (Yaru / Papirus / Conky)"
  apt_install_missing "${LOOK_PACKAGES[@]}"
  if apt_package_available conky-all; then
    apt_install_missing conky-all
  else
    apt_install_missing conky
  fi
  state_append_list "MODULES" "look-packages"
}
