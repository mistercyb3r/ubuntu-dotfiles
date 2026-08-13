#!/usr/bin/env bash
# Optional game / mod development prep. Does not install Steam, Godot, Blender, or Wine.
# Enabled with ./install.sh --gaming

install_gaming_packages() {
  if [[ "${ENABLE_GAMING:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Gaming/mod module: lightweight language extras only"
  log_info "Not installing Steam, Godot, Blender, Proton, or Wine automatically."

  apt_install_missing lua5.4
  if command_exists git-lfs; then
    log_skip "git-lfs already installed"
  else
    apt_install_missing git-lfs
  fi

  log_info "Install large apps yourself when needed:"
  log_info "  sudo apt-get install godot4 blender   # if packaged"
  log_info "  Steam: Ubuntu Software or https://store.steampowered.com"
  state_append_list "MODULES" "gaming-packages"
}
