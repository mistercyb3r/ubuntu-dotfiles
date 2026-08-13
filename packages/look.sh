#!/usr/bin/env bash
# Visual packages for the optional "modded" look.
# Ubuntu archive only. No theme PPAs, no random GitHub rices.

LOOK_PACKAGES=(
  neofetch
  papirus-icon-theme
  yaru-theme-gtk
  yaru-theme-icon
  gnome-tweaks
  gnome-shell-extension-manager
  cmatrix
)

LOOK_OPTIONAL=(
  fastfetch
)

install_look_packages() {
  if [[ "${SKIP_LOOK:-0}" == "1" ]]; then
    log_skip "Look packages (--no-look)"
    return 0
  fi

  log_info "Installing visual packages (neofetch, icons, terminal extras)"
  apt_install_missing "${LOOK_PACKAGES[@]}"
  apt_install_missing "${LOOK_OPTIONAL[@]}"
  state_append_list "MODULES" "look-packages"
}
