#!/usr/bin/env bash
# Starship and tmux user configuration.

configure_terminal() {
  log_info "Configuring Starship and tmux"

  mkdir -p "${XDG_CONFIG_HOME}"
  install_file "${REPO_ROOT}/terminal/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
  install_file "${REPO_ROOT}/terminal/tmux.conf" "${HOME}/.tmux.conf"

  link_script "${REPO_ROOT}/scripts/system-info.sh" "system-info"
  link_script "${REPO_ROOT}/scripts/system-update.sh" "system-update"
  link_script "${REPO_ROOT}/scripts/cleanup.sh" "cleanup-system"
  link_script "${REPO_ROOT}/scripts/new-project.sh" "new-project"
  link_script "${REPO_ROOT}/scripts/server.sh" "server"
  link_script "${REPO_ROOT}/scripts/check-secrets.sh" "check-secrets"

  state_append_list "MODULES" "terminal"
}
