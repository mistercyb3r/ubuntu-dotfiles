#!/usr/bin/env bash
# Core visual terminal: Starship, Fastfetch, Ptyxis, tmux, Yazi, helpers.

configure_terminal() {
  log_info "Installing the workstation terminal configuration"

  mkdir -p "${XDG_CONFIG_HOME}/fastfetch" \
    "${XDG_CONFIG_HOME}/yazi" \
    "${XDG_DATA_HOME:-${HOME}/.local/share}/org.gnome.Ptyxis/palettes"

  install_file "${REPO_ROOT}/terminal/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
  install_file "${REPO_ROOT}/terminal/tmux.conf" "${HOME}/.tmux.conf"
  install_file "${REPO_ROOT}/terminal/fastfetch.jsonc" "${XDG_CONFIG_HOME}/fastfetch/config.jsonc"
  install_file "${REPO_ROOT}/terminal/yazi/yazi.toml" "${XDG_CONFIG_HOME}/yazi/yazi.toml"
  install_file "${REPO_ROOT}/terminal/yazi/theme.toml" "${XDG_CONFIG_HOME}/yazi/theme.toml"
  install_file "${REPO_ROOT}/terminal/ptyxis/Workstation.palette" \
    "${XDG_DATA_HOME:-${HOME}/.local/share}/org.gnome.Ptyxis/palettes/Workstation.palette"

  _terminal_install_nerd_font
  _terminal_theme_ptyxis
  _terminal_prefer_ptyxis
  _terminal_theme_gnome_fallback

  link_script "${REPO_ROOT}/scripts/system-info.sh" "system-info"
  link_script "${REPO_ROOT}/scripts/system-update.sh" "system-update"
  link_script "${REPO_ROOT}/scripts/cleanup.sh" "cleanup-system"
  link_script "${REPO_ROOT}/scripts/new-project.sh" "new-project"
  link_script "${REPO_ROOT}/scripts/server.sh" "server"
  link_script "${REPO_ROOT}/scripts/check-secrets.sh" "check-secrets"
  link_script "${REPO_ROOT}/scripts/preview-terminal.sh" "preview-terminal"
  link_script "${REPO_ROOT}/scripts/dotfiles-health.sh" "dotfiles-health"
  link_script "${REPO_ROOT}/scripts/theme-health.sh" "theme-health"

  state_append_list "MODULES" "terminal"
}

_terminal_install_nerd_font() {
  # Same helper as look; Nerd Font is required for the prompt, not optional.
  if declare -F _look_install_nerd_font >/dev/null 2>&1; then
    _look_install_nerd_font
    return 0
  fi
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/modules/look.sh"
  _look_install_nerd_font
}

# Apply Nord palette + subtle opacity to the default Ptyxis profile.
# Ptyxis cannot source theme/palette.env; colours live in Workstation.palette
# (mapped in theme/palette.md). Opacity is UDF_OPACITY from palette.env.
_terminal_theme_ptyxis() {
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/theme/palette.env"
  local opacity="${UDF_OPACITY:-0.92}"
  local dest="${XDG_DATA_HOME:-${HOME}/.local/share}/org.gnome.Ptyxis/palettes/Workstation.palette"

  if [[ ! -f "${dest}" ]] && ! is_dry_run; then
    log_warn "Ptyxis palette was not installed at ${dest}"
    return 0
  fi

  if ! command_exists gsettings && ! command_exists dconf; then
    log_warn "gsettings/dconf unavailable; Ptyxis palette file is in place, profile not applied"
    return 0
  fi

  if command_exists gsettings; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/look.sh"
  fi

  local uuid=""
  _ptyxis_ensure_profile
  uuid="${_PTYXIS_PROFILE_UUID:-}"
  if [[ -z "${uuid}" ]]; then
    log_warn "Could not resolve a Ptyxis profile; open Ptyxis once on Ubuntu, then re-run ./install.sh"
    return 0
  fi

  local schema="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${uuid}/"
  log_info "Theming Ptyxis profile ${uuid} (Workstation palette, opacity ${opacity})"

  _ptyxis_profile_set "${schema}" "${uuid}" palette "'Workstation'" "'Workstation'"
  _ptyxis_profile_set "${schema}" "${uuid}" opacity "${opacity}" "${opacity}"
  _ptyxis_profile_set "${schema}" "${uuid}" login-shell "true" "true"
  _ptyxis_profile_set "${schema}" "${uuid}" use-custom-command "true" "true"
  _ptyxis_profile_set "${schema}" "${uuid}" custom-command "'zsh'" "'zsh'"
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd Font'; then
    _ptyxis_profile_set "${schema}" "${uuid}" use-system-font "false" "false"
    _ptyxis_profile_set "${schema}" "${uuid}" font-name "'JetBrainsMono Nerd Font 12'" "'JetBrainsMono Nerd Font 12'"
  fi
}

# Create a stable profile UUID if Ptyxis has never been opened.
# Sets _PTYXIS_PROFILE_UUID (do not capture stdout — log_* writes there).
_ptyxis_ensure_profile() {
  local uuid=""
  _PTYXIS_PROFILE_UUID=""
  if command_exists dconf; then
    uuid="$(dconf read /org/gnome/Ptyxis/default-profile-uuid 2>/dev/null | tr -d "'" || true)"
  fi
  if [[ -z "${uuid}" ]] && command_exists gsettings; then
    uuid="$(gsettings get org.gnome.Ptyxis default-profile-uuid 2>/dev/null | tr -d "'" || true)"
  fi
  if [[ -z "${uuid}" || "${uuid}" == "@ms nothing" ]]; then
    uuid="ubuntu-dotfiles"
    if is_dry_run; then
      log_dry "create Ptyxis profile ${uuid}"
      _PTYXIS_PROFILE_UUID="${uuid}"
      return 0
    fi
    if command_exists gsettings; then
      _gset org.gnome.Ptyxis default-profile-uuid "'${uuid}'"
    elif command_exists dconf; then
      dconf write /org/gnome/Ptyxis/default-profile-uuid "'${uuid}'" || true
    fi
  fi

  if ! is_dry_run; then
    _ptyxis_ensure_uuid_listed "${uuid}"
  fi
  _PTYXIS_PROFILE_UUID="${uuid}"
}

_ptyxis_ensure_uuid_listed() {
  local uuid="$1"
  local current=""
  if command_exists dconf; then
    current="$(dconf read /org/gnome/Ptyxis/profile-uuids 2>/dev/null || true)"
  fi
  if [[ "${current}" == *"${uuid}"* ]]; then
    return 0
  fi
  if command_exists gsettings; then
    local listed
    listed="$(gsettings get org.gnome.Ptyxis profile-uuids 2>/dev/null || true)"
    if [[ "${listed}" == *"${uuid}"* ]]; then
      return 0
    fi
    if [[ -z "${listed}" || "${listed}" == "@as []" ]]; then
      _gset org.gnome.Ptyxis profile-uuids "['${uuid}']"
      return 0
    fi
  fi
  if command_exists dconf; then
    if [[ -z "${current}" || "${current}" == "@as []" ]]; then
      dconf write /org/gnome/Ptyxis/profile-uuids "['${uuid}']" || true
    else
      local stripped="${current#\[}"
      stripped="${stripped%\]}"
      dconf write /org/gnome/Ptyxis/profile-uuids "[${stripped}, '${uuid}']" || true
    fi
  fi
}

# Set a Ptyxis profile key via gsettings when the schema exists, else dconf.
_ptyxis_profile_set() {
  local schema_path="$1"
  local uuid="$2"
  local key="$3"
  local gvalue="$4"
  local dvalue="$5"
  local dpath="/org/gnome/Ptyxis/Profiles/${uuid}/${key}"

  if command_exists gsettings && declare -F _gset_rel >/dev/null 2>&1; then
    if gsettings list-relocatable-schemas 2>/dev/null | grep -qx org.gnome.Ptyxis.Profile; then
      if gsettings list-keys "${schema_path}" 2>/dev/null | grep -qx "${key}"; then
        _gset_rel "${schema_path}" "${key}" "${gvalue}"
        return 0
      fi
    fi
  fi

  if is_dry_run; then
    log_dry "dconf write ${dpath} ${dvalue}"
    return 0
  fi
  if command_exists dconf; then
    if dconf write "${dpath}" "${dvalue}"; then
      log_success "Ptyxis ${key} = ${dvalue}"
      return 0
    fi
  fi
  log_skip "Ptyxis profile key not available here: ${key}"
}

_terminal_prefer_ptyxis() {
  if ! command_exists ptyxis && [[ ! -x /usr/bin/ptyxis ]]; then
    log_warn "Ptyxis is not installed; Super+T will keep using the current default terminal"
    return 0
  fi

  if command_exists gsettings; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    _gset org.gnome.desktop.default-applications.terminal exec "'ptyxis'"
    _gset org.gnome.desktop.default-applications.terminal exec-arg "'--new-window'"
  fi

  if [[ -x /usr/bin/ptyxis ]] && command_exists update-alternatives; then
    if is_dry_run; then
      log_dry "update-alternatives --set x-terminal-emulator /usr/bin/ptyxis"
    else
      sudo_run update-alternatives --install /usr/bin/x-terminal-emulator \
        x-terminal-emulator /usr/bin/ptyxis 50 || true
      sudo_run update-alternatives --set x-terminal-emulator /usr/bin/ptyxis || true
    fi
  fi
  log_info "Default terminal set to Ptyxis (Super+T / Ctrl+Alt+T after logout)"
}

_terminal_theme_gnome_fallback() {
  # GNOME Terminal stays as a fallback and must use the same Nord palette as Ptyxis.
  if ! command_exists gsettings; then
    return 0
  fi
  if ! gsettings list-schemas 2>/dev/null | grep -qx org.gnome.Terminal.ProfilesList; then
    return 0
  fi
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/settings.sh"
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/look.sh"
  gnome_apply_terminal_theme
}
