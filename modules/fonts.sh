#!/usr/bin/env bash
# Programming fonts. JetBrains Mono is the default (Ubuntu package).

configure_fonts() {
  log_info "Configuring programming fonts"

  apt_install_missing fonts-jetbrains-mono

  if apt_package_available fonts-firacode; then
    apt_install_missing fonts-firacode
  fi

  if command_exists gsettings && { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; }; then
    if command_exists fc-list && fc-list | grep -qi 'JetBrainsMono Nerd Font'; then
      _gset_if_exists org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 12"
    else
      _gset_if_exists org.gnome.desktop.interface monospace-font-name "JetBrains Mono 12"
    fi
  fi

  log_info "Monospace font: JetBrainsMono Nerd Font when installed, else JetBrains Mono."
  state_append_list "MODULES" "fonts"
}

_gset_if_exists() {
  local schema="$1"
  local key="$2"
  local value="$3"
  if ! command_exists gsettings; then
    return 0
  fi
  if gsettings list-keys "${schema}" >/dev/null 2>&1 \
    && gsettings list-keys "${schema}" | grep -qx "${key}"; then
    if is_dry_run; then
      log_dry "gsettings set ${schema} ${key} ${value}"
    else
      gsettings set "${schema}" "${key}" "${value}"
    fi
  fi
}
