#!/usr/bin/env bash
# Optional game/mod project layout. No engine downloads.

configure_gaming() {
  if [[ "${ENABLE_GAMING:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Preparing game/mod project directories"
  mkdir -p "${PROJECTS_ROOT:-${HOME}/Projects}/games"
  state_append_list "MODULES" "gaming"
}
