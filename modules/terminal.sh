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
  _terminal_theme_btop

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
  link_script "${REPO_ROOT}/scripts/desk-stats.sh" "stats"
  link_script "${REPO_ROOT}/scripts/apply-look.sh" "apply-look"

  state_append_list "MODULES" "terminal"
}

_terminal_theme_btop() {
  mkdir -p "${XDG_CONFIG_HOME}/btop/themes"
  install_file "${REPO_ROOT}/terminal/btop.theme" "${XDG_CONFIG_HOME}/btop/themes/ubuntu-dotfiles.theme"
  local conf="${XDG_CONFIG_HOME}/btop/btop.conf"
  if is_dry_run; then
    log_dry "set btop color_theme=ubuntu-dotfiles"
    return 0
  fi
  mkdir -p "$(dirname "${conf}")"
  if [[ -f "${conf}" ]] && grep -q '^color_theme' "${conf}"; then
    local tmp
    tmp="$(mktemp)"
    awk '
      /^color_theme/ {print "color_theme = \"ubuntu-dotfiles\""; next}
      {print}
    ' "${conf}" > "${tmp}"
    mv "${tmp}" "${conf}"
  elif [[ -f "${conf}" ]]; then
    printf '\ncolor_theme = "ubuntu-dotfiles"\ntheme_background = False\n' >> "${conf}"
  else
    printf 'color_theme = "ubuntu-dotfiles"\ntheme_background = False\n' > "${conf}"
  fi
  log_success "btop theme: ubuntu-dotfiles"
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

# Apply Nord palette + subtle opacity to every Ptyxis profile.
# Always writes dconf; do not skip just because a gsettings key lookup failed.
_terminal_theme_ptyxis() {
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/theme/palette.env"
  local opacity="${UDF_OPACITY:-0.92}"
  local dest_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/org.gnome.Ptyxis/palettes"
  local dest="${dest_dir}/Workstation.palette"
  local src="${REPO_ROOT}/terminal/ptyxis/Workstation.palette"

  mkdir -p "${dest_dir}"
  if [[ -f "${src}" ]]; then
    install_file "${src}" "${dest}"
  fi

  if [[ ! -f "${dest}" ]] && ! is_dry_run; then
    log_warn "Ptyxis palette was not installed at ${dest}"
    return 0
  fi

  if command_exists gsettings; then
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/settings.sh"
    # shellcheck disable=SC1091
    . "${REPO_ROOT}/gnome/look.sh"
  fi

  _ptyxis_ensure_profile
  local uuid=""
  local -a uuids=()
  while IFS= read -r uuid; do
    [[ -n "${uuid}" ]] && uuids+=("${uuid}")
  done < <(_ptyxis_all_uuids)

  if [[ ${#uuids[@]} -eq 0 ]]; then
    uuids+=("${_PTYXIS_PROFILE_UUID:-ubuntu-dotfiles}")
  fi

  for uuid in "${uuids[@]}"; do
    log_info "Theming Ptyxis profile ${uuid} (Workstation, opacity ${opacity})"
    _ptyxis_force_write "${uuid}" palette "'Workstation'"
    _ptyxis_force_write "${uuid}" opacity "${opacity}"
    _ptyxis_force_write "${uuid}" login-shell "true"
    _ptyxis_force_write "${uuid}" use-custom-command "true"
    _ptyxis_force_write "${uuid}" custom-command "'zsh'"
    if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd Font'; then
      _ptyxis_force_write "${uuid}" use-system-font "false"
      _ptyxis_force_write "${uuid}" font-name "'JetBrainsMono Nerd Font 12'"
    fi
  done
}

_ptyxis_all_uuids() {
  local raw=""
  if command_exists dconf; then
    raw="$(dconf read /org/gnome/Ptyxis/profile-uuids 2>/dev/null || true)"
  fi
  if [[ -z "${raw}" ]] && command_exists gsettings; then
    raw="$(gsettings get org.gnome.Ptyxis profile-uuids 2>/dev/null || true)"
  fi
  printf '%s\n' "${raw}" | tr -d "[]'," | tr ' ' '\n' | awk 'NF'
  if [[ -n "${_PTYXIS_PROFILE_UUID:-}" ]]; then
    printf '%s\n' "${_PTYXIS_PROFILE_UUID}"
  fi
}

# dconf first — this is what actually changes a running Ptyxis profile.
_ptyxis_force_write() {
  local uuid="$1"
  local key="$2"
  local value="$3"
  local dpath="/org/gnome/Ptyxis/Profiles/${uuid}/${key}"
  local schema="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${uuid}/"

  if is_dry_run; then
    log_dry "dconf write ${dpath} ${value}"
    return 0
  fi
  if command_exists dconf; then
    if dconf write "${dpath}" "${value}"; then
      log_success "Ptyxis ${uuid} ${key} = ${value}"
    else
      log_warn "dconf write failed: ${dpath}"
    fi
  fi
  if command_exists gsettings && gsettings list-relocatable-schemas 2>/dev/null | grep -qx org.gnome.Ptyxis.Profile; then
    # shellcheck disable=SC2086
    gsettings set "${schema}" "${key}" ${value} >/dev/null 2>&1 || true
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
