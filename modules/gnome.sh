#!/usr/bin/env bash
# GNOME productivity settings. No extension installation by default.

configure_gnome() {
  if [[ "${SKIP_GNOME:-0}" == "1" ]]; then
    log_skip "GNOME (--no-gnome)"
    return 0
  fi

  if ! command_exists gsettings; then
    log_skip "gsettings not found; this session is not a GNOME desktop"
    return 0
  fi

  if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    log_warn "No graphical session detected. GNOME settings will be skipped."
    log_warn "Re-run ./install.sh after logging into the Ubuntu desktop, or run: gnome/settings.sh"
    return 0
  fi

  log_info "Applying GNOME productivity settings (no extensions)"
  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/settings.sh"
  gnome_apply_settings

  # shellcheck disable=SC1091
  . "${REPO_ROOT}/gnome/extensions.sh"
  gnome_document_extensions

  state_append_list "MODULES" "gnome"
}
