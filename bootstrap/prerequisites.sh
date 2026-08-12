#!/usr/bin/env bash
# Bootstrap: tools required before the rest of the installer can run.
# Idempotent. Does not install developer applications.

bootstrap_prerequisites() {
  log_info "Checking installer prerequisites"

  require_command bash
  require_command uname
  require_command grep
  require_command awk
  require_command sed
  require_command mkdir
  require_command cp
  require_command mv

  if ! command_exists curl && ! command_exists wget; then
    log_info "Neither curl nor wget is available; installing curl first"
    sudo_run apt-get update
    sudo_run apt-get install -y --no-install-recommends curl ca-certificates
  fi

  local needed=()
  local pkg
  for pkg in ca-certificates curl wget gnupg lsb-release software-properties-common \
             apt-transport-https coreutils findutils grep sed gawk tar gzip unzip; do
    if ! package_installed "${pkg}"; then
      needed+=("${pkg}")
    fi
  done

  if [[ ${#needed[@]} -gt 0 ]]; then
    log_info "Installing bootstrap packages: ${needed[*]}"
    apt_update_once
    sudo_run apt-get install -y --no-install-recommends "${needed[@]}"
  else
    log_skip "Bootstrap packages already present"
  fi

  if ! command_exists git; then
    apt_install_missing git
  fi

  ensure_state_dirs
  save_repo_path
  log_success "Prerequisites ready"
}
