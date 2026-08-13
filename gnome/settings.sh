#!/usr/bin/env bash
# GNOME settings for a developer laptop. Each key is applied only if it exists
# on this Ubuntu version. No extensions are installed here.

gnome_apply_settings() {
  log_info "Applying GNOME settings (idempotent gsettings)"

  # Appearance
  _gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
  _gset org.gnome.desktop.interface gtk-theme "'Yaru-dark'"
  _gset org.gnome.desktop.interface icon-theme "'Yaru'"
  _gset org.gnome.desktop.interface monospace-font-name "'JetBrains Mono 12'"
  _gset org.gnome.desktop.interface enable-hot-corners "false"
  _gset org.gnome.desktop.interface clock-show-weekday "true"
  _gset org.gnome.desktop.interface clock-show-seconds "false"
  _gset org.gnome.desktop.interface show-battery-percentage "true"

  # Keep animations. Disabling them makes GNOME feel broken and saves little on UHD 620.
  _gset org.gnome.desktop.interface enable-animations "true"

  # Workspaces: four static workspaces, wrap around
  _gset org.gnome.mutter dynamic-workspaces "false"
  _gset org.gnome.desktop.wm.preferences num-workspaces "4"
  _gset org.gnome.desktop.wm.preferences workspace-names "['Code', 'Browser', 'Comms', 'Misc']"
  _gset org.gnome.mutter workspaces-only-on-primary "true"
  _gset org.gnome.shell.overrides workspaces-only-on-primary "true"

  # Window focus
  _gset org.gnome.desktop.wm.preferences button-layout "'appmenu:minimize,maximize,close'"
  _gset org.gnome.desktop.wm.preferences focus-mode "'click'"
  _gset org.gnome.desktop.wm.preferences auto-raise "false"

  # Ubuntu's default left launcher is a full-height side panel.
  # Turn it into a centred bottom dock (the usual macOS-style setup).
  gnome_apply_dock

  # Touchpad (Latitude 5400)
  _gset org.gnome.desktop.peripherals.touchpad tap-to-click "true"
  _gset org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled "true"
  _gset org.gnome.desktop.peripherals.touchpad natural-scroll "true"
  _gset org.gnome.desktop.peripherals.touchpad disable-while-typing "true"

  # Power: balanced laptop behaviour. Do not force aggressive sleep that kills SSH/tmux.
  _gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "'nothing'"
  _gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "'suspend'"
  _gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout "1500"
  _gset org.gnome.settings-daemon.plugins.power idle-dim "true"
  _gset org.gnome.desktop.session idle-delay "uint32 300"

  # File manager
  _gset org.gnome.nautilus.preferences default-folder-viewer "'list-view'"
  _gset org.gnome.nautilus.preferences show-hidden-files "false"
  _gset org.gnome.nautilus.preferences sort-directories-first "true"
  _gset org.gtk.Settings.FileChooser sort-directories-first "true"
  _gset org.gtk.gtk4.Settings.FileChooser sort-directories-first "true"

  # Privacy: keep location off; do not disable the screensaver lock.
  _gset org.gnome.system.location enabled "false"
  _gset org.gnome.desktop.privacy remember-recent-files "true"
  _gset org.gnome.desktop.privacy remove-old-trash-files "true"
  _gset org.gnome.desktop.privacy remove-old-temp-files "true"
  _gset org.gnome.desktop.screensaver lock-enabled "true"
  _gset org.gnome.desktop.screensaver lock-delay "uint32 0"

  # Night light: easier on the eyes for evening coding
  _gset org.gnome.settings-daemon.plugins.color night-light-enabled "true"
  _gset org.gnome.settings-daemon.plugins.color night-light-temperature "uint32 4000"

  _gnome_keyboard_shortcuts
  log_success "GNOME settings applied"
}

gnome_apply_dock() {
  log_info "Moving the Ubuntu side launcher to a centred bottom dock"

  # Position: bottom, not left. extend-height=false is what stops the "side panel".
  _gset org.gnome.shell.extensions.dash-to-dock dock-position "'BOTTOM'"
  _gset org.gnome.shell.extensions.dash-to-dock extend-height "false"
  _gset org.gnome.shell.extensions.dash-to-dock dock-alignment "'CENTER'"

  # Always visible like a dock, not an auto-hiding side strip.
  _gset org.gnome.shell.extensions.dash-to-dock dock-fixed "true"
  _gset org.gnome.shell.extensions.dash-to-dock autohide "false"
  _gset org.gnome.shell.extensions.dash-to-dock intellihide "false"
  _gset org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen "true"

  _gset org.gnome.shell.extensions.dash-to-dock custom-theme-shrink "true"
  _gset org.gnome.shell.extensions.dash-to-dock transparency-mode "'FIXED'"
  _gset org.gnome.shell.extensions.dash-to-dock background-opacity "0.55"
  _gset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size "42"
  _gset org.gnome.shell.extensions.dash-to-dock running-indicator-style "'DOTS'"
  _gset org.gnome.shell.extensions.dash-to-dock click-action "'minimize-or-previews'"
  _gset org.gnome.shell.extensions.dash-to-dock isolate-workspaces "true"
  _gset org.gnome.shell.extensions.dash-to-dock show-trash "false"
  _gset org.gnome.shell.extensions.dash-to-dock show-mounts "false"
  _gset org.gnome.shell.extensions.dash-to-dock show-show-apps-button "true"
  _gset org.gnome.shell.extensions.dash-to-dock show-apps-at-top "false"
  _gset org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup "true"
  _gset org.gnome.shell.extensions.dash-to-dock unity-backlit-items "false"
  _gset org.gnome.shell.extensions.dash-to-dock apply-custom-theme "false"
}

_gnome_keyboard_shortcuts() {
  # Super+T → GNOME Terminal (Ctrl+Alt+T remains the Ubuntu default too)
  _gset org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"

  # Super+E → Files (usually already bound; set explicitly)
  _gset org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

  # Workspace switching: Super+1..4 is used by the dock on Ubuntu.
  # Use Super+Alt+1..4 for workspaces to avoid fighting the dock.
  _gset org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super><Alt>1']"
  _gset org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super><Alt>2']"
  _gset org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super><Alt>3']"
  _gset org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super><Alt>4']"
  _gset org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Shift><Alt>1']"
  _gset org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Shift><Alt>2']"
  _gset org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Shift><Alt>3']"
  _gset org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Shift><Alt>4']"
}

_gset() {
  local schema="$1"
  local key="$2"
  local value="$3"

  if ! command_exists gsettings; then
    return 0
  fi
  if ! gsettings list-schemas 2>/dev/null | grep -qx "${schema}" \
    && ! gsettings list-relocatable-schemas 2>/dev/null | grep -qx "${schema}"; then
    log_skip "gsettings schema not present: ${schema}"
    return 0
  fi
  if ! gsettings list-keys "${schema}" 2>/dev/null | grep -qx "${key}"; then
    log_skip "gsettings key not present: ${schema} ${key}"
    return 0
  fi

  if is_dry_run; then
    log_dry "gsettings set ${schema} ${key} ${value}"
    return 0
  fi

  # shellcheck disable=SC2086
  if gsettings set "${schema}" "${key}" ${value}; then
    log_success "${schema} ${key} = ${value}"
  else
    log_warn "Failed to set ${schema} ${key}"
  fi
}

# Allow running this file directly on the Ubuntu desktop after install.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "${_here}/../lib/common.sh"
  gnome_apply_settings
fi
