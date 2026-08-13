#!/usr/bin/env bash
# Extra GNOME + GNOME Terminal styling. Sourced by modules/look.sh.
# Uses only Ubuntu-shipped themes (Yaru, Papirus) and dconf/gsettings.

gnome_apply_look() {
  log_info "Applying GNOME look (Nordic Yaru + Papirus, polar wallpaper)"

  if ! command_exists gsettings; then
    log_skip "gsettings not found"
    return 0
  fi

  # Frost teal is the closest shipped GNOME accent to the Nordic palette.
  # Do not install a full custom GTK theme — libadwaita on GNOME 50 breaks those.
  _gset org.gnome.desktop.interface color-scheme "'prefer-dark'"
  _gset org.gnome.desktop.interface accent-color "'teal'"
  if [[ -d /usr/share/themes/Yaru-teal-dark ]]; then
    _gset org.gnome.desktop.interface gtk-theme "'Yaru-teal-dark'"
  else
    _gset org.gnome.desktop.interface gtk-theme "'Yaru-dark'"
  fi

  if [[ -d /usr/share/icons/Papirus-Dark ]]; then
    _gset org.gnome.desktop.interface icon-theme "'Papirus-Dark'"
  else
    _gset org.gnome.desktop.interface icon-theme "'Yaru'"
  fi

  _gset org.gnome.desktop.interface cursor-theme "'Yaru'"
  _look_set_ui_font
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd Font'; then
    _gset org.gnome.desktop.interface monospace-font-name "'JetBrainsMono Nerd Font 12'"
  else
    _gset org.gnome.desktop.interface monospace-font-name "'JetBrains Mono 12'"
  fi
  _gset org.gnome.desktop.interface enable-animations "true"

  gnome_apply_dock
  _look_set_wallpaper
}

_look_set_ui_font() {
  # Prefer a font already on Ubuntu. Inter only if the archive package was installed.
  if fc-list 2>/dev/null | grep -qi 'Ubuntu Sans'; then
    _gset org.gnome.desktop.interface font-name "'Ubuntu Sans 11'"
    _gset org.gnome.desktop.interface document-font-name "'Ubuntu Sans 11'"
  elif fc-list 2>/dev/null | grep -qi '^Inter:'; then
    _gset org.gnome.desktop.interface font-name "'Inter 11'"
    _gset org.gnome.desktop.interface document-font-name "'Inter 11'"
  fi
}

_look_set_wallpaper() {
  # GNOME wallpaper reliably accepts PNG. SVG often shows as a blank/old background.
  local dest="${XDG_DATA_HOME:-${HOME}/.local/share}/backgrounds/ubuntu-dotfiles-nordic.png"
  local root="${REPO_ROOT:-}"
  if [[ -z "${root}" ]]; then
    root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  fi
  local src="${root}/theme/wallpapers/nordic-polar.png"
  local wp=""

  if [[ ! -f "${src}" ]]; then
    src="${root}/theme/wallpapers/nordic-polar.svg"
    dest="${XDG_DATA_HOME:-${HOME}/.local/share}/backgrounds/ubuntu-dotfiles-nordic.svg"
  fi

  if [[ -f "${src}" ]]; then
    if is_dry_run; then
      log_dry "install wallpaper ${src} -> ${dest}"
      wp="${dest}"
    else
      mkdir -p "$(dirname "${dest}")"
      install_file "${src}" "${dest}"
      wp="${dest}"
    fi
  fi

  if [[ -z "${wp}" ]]; then
    local candidate
    for candidate in \
      /usr/share/backgrounds/ubuntu-wallpaper-d.png \
      /usr/share/backgrounds/ubuntu-wallpaper-u.png \
      /usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png \
      /usr/share/backgrounds/warty-final-ubuntu.png
    do
      if [[ -f "${candidate}" ]]; then
        wp="${candidate}"
        break
      fi
    done
  fi

  if [[ -n "${wp}" ]]; then
    _gset org.gnome.desktop.background picture-uri "'file://${wp}'"
    _gset org.gnome.desktop.background picture-uri-dark "'file://${wp}'"
    _gset org.gnome.desktop.background picture-options "'zoom'"
    _gset org.gnome.desktop.background primary-color "'#1F232B'"
    log_success "Wallpaper: ${wp}"
  else
    log_skip "No wallpaper found; left the current one"
  fi
}

# Same Nord palette as Ptyxis (theme/palette.md). Fallback only.
gnome_apply_terminal_theme() {
  if ! command_exists gsettings; then
    return 0
  fi
  if ! gsettings list-schemas 2>/dev/null | grep -qx org.gnome.Terminal.ProfilesList; then
    log_skip "GNOME Terminal is not installed; skip terminal palette"
    return 0
  fi

  local id
  id="$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")"
  if [[ -z "${id}" ]]; then
    log_skip "No default GNOME Terminal profile"
    return 0
  fi

  local schema="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${id}/"
  log_info "Theming GNOME Terminal profile ${id} (workstation palette, zsh)"

  _gset_rel "${schema}" use-theme-colors "false"
  _gset_rel "${schema}" background-color "'#2E3440'"
  _gset_rel "${schema}" foreground-color "'#D8DEE9'"
  _gset_rel "${schema}" cursor-colors-set "true"
  _gset_rel "${schema}" cursor-background-color "'#88C0D0'"
  _gset_rel "${schema}" cursor-foreground-color "'#2E3440'"
  _gset_rel "${schema}" bold-color-same-as-fg "true"
  _gset_rel "${schema}" palette "['#3B4252', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#D8DEE9', '#4C566A', '#BF616A', '#A3BE8C', '#EBCB8B', '#81A1C1', '#B48EAD', '#88C0D0', '#ECEFF4']"
  _gset_rel "${schema}" use-transparent-background "true"
  _gset_rel "${schema}" background-transparency-percent "8"
  _gset_rel "${schema}" use-system-font "false"
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd Font'; then
    _gset_rel "${schema}" font "'JetBrainsMono Nerd Font 12'"
  else
    _gset_rel "${schema}" font "'JetBrains Mono 12'"
  fi
  _gset_rel "${schema}" audible-bell "false"
  _gset_rel "${schema}" cursor-shape "'ibeam'"
  _gset_rel "${schema}" default-size-columns "120"
  _gset_rel "${schema}" default-size-rows "32"
  _gset_rel "${schema}" scrollback-unlimited "true"
  _gset_rel "${schema}" use-custom-command "true"
  _gset_rel "${schema}" custom-command "'zsh'"
}

# Relocatable gsettings (GNOME Terminal profiles).
_gset_rel() {
  local schema_path="$1"
  local key="$2"
  local value="$3"
  local base="${schema_path%%:*}"

  if ! command_exists gsettings; then
    return 0
  fi
  if ! gsettings list-relocatable-schemas 2>/dev/null | grep -qx "${base}"; then
    log_skip "relocatable schema not present: ${base}"
    return 0
  fi
  if is_dry_run; then
    log_dry "gsettings set ${schema_path} ${key} ${value}"
    return 0
  fi
  # shellcheck disable=SC2086
  if gsettings set "${schema_path}" "${key}" ${value}; then
    log_success "${key} = ${value}"
  else
    log_warn "Failed to set ${schema_path} ${key}"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "${_here}/../lib/common.sh"
  # shellcheck disable=SC1091
  . "${_here}/settings.sh"
  gnome_apply_look
  gnome_apply_terminal_theme
fi
