#!/usr/bin/env bash
# Programming fonts. JetBrains Mono is the default (Ubuntu package).

configure_fonts() {
  log_info "Configuring programming fonts"

  apt_install_missing fonts-jetbrains-mono

  if apt_package_available fonts-firacode; then
    apt_install_missing fonts-firacode
  fi

  if command_exists gsettings && { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; }; then
    _gset_if_exists org.gnome.desktop.interface monospace-font-name "JetBrains Mono 12"
  fi

  log_info "Default monospace font: JetBrains Mono (Fira Code is also installed when available)."
  log_info "Set it in GNOME Terminal: Preferences → Profile → Text → Custom font."
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
