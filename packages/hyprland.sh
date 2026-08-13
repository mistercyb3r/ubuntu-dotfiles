#!/usr/bin/env bash
# Optional Hyprland session. Never installed unless ./install.sh --hyprland.

HYPRLAND_PACKAGES=(
  hyprland
  waybar
  wofi
  xdg-desktop-portal-hyprland
)

install_hyprland_packages() {
  if [[ "${ENABLE_HYPRLAND:-0}" != "1" ]]; then
    log_skip "Hyprland (pass --hyprland to install)"
    return 0
  fi

  log_info "Installing Hyprland session packages (optional; GNOME remains the default)"
  log_warn "Hyprland on a Latitude 5400 is a second session, not a replacement for GNOME."
  apt_install_missing "${HYPRLAND_PACKAGES[@]}"
  state_append_list "MODULES" "hyprland-packages"
}
