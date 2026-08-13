#!/usr/bin/env bash
# Optional Hyprland session. Shares theme/palette.md. GNOME stays the login default.

configure_hyprland() {
  if [[ "${ENABLE_HYPRLAND:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Writing Hyprland config (same palette as Ptyxis / Starship)"
  mkdir -p "${XDG_CONFIG_HOME}/hypr" "${XDG_CONFIG_HOME}/waybar"
  install_file "${REPO_ROOT}/hyprland/hyprland.conf" "${XDG_CONFIG_HOME}/hypr/hyprland.conf"
  install_file "${REPO_ROOT}/hyprland/waybar/config.jsonc" "${XDG_CONFIG_HOME}/waybar/config.jsonc"
  install_file "${REPO_ROOT}/hyprland/waybar/style.css" "${XDG_CONFIG_HOME}/waybar/style.css"
  state_append_list "MODULES" "hyprland"
  log_info "Choose Hyprland from the login-screen session menu. GNOME is unchanged."
}
