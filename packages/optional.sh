#!/usr/bin/env bash
# Optional software: Docker (official apt repo), Tailscale (docs + optional package),
# GNOME Tweaks. Nothing here is required for a working developer shell.

install_optional_packages() {
  if [[ "${SKIP_DOCKER:-0}" != "1" ]]; then
    install_docker
  else
    log_skip "Docker (--no-docker)"
  fi

  if [[ "${INSTALL_PROFILE}" == "full" ]]; then
    install_gnome_tweaks_if_desktop
    install_tailscale_package
  else
    log_skip "Optional full-profile packages (gnome-tweaks, tailscale)"
  fi

  state_append_list "MODULES" "optional"
}

install_gnome_tweaks_if_desktop() {
  if [[ "${SKIP_GNOME:-0}" == "1" ]]; then
    return 0
  fi
  if ! os_has_gnome && [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* ]]; then
    log_skip "GNOME Tweaks (no GNOME desktop detected)"
    return 0
  fi
  apt_install_missing gnome-tweaks
}

# Install the Tailscale package only. Never run `tailscale up` or use an auth key.
install_tailscale_package() {
  if command_exists tailscale; then
    log_skip "Tailscale already installed"
    return 0
  fi

  log_info "Tailscale is optional. The package will be installed; you must log in yourself."
  log_info "This installer will NOT run 'tailscale up' and will NOT use an auth key."

  if [[ "${ASSUME_YES}" != "1" ]] && ! is_dry_run; then
    if ! confirm "Install the Tailscale package now? (you will log in later)"; then
      log_skip "Tailscale package (declined)"
      return 0
    fi
  fi

  if apt_package_available tailscale; then
    apt_install_missing tailscale
    log_success "Tailscale package installed. See docs/tailscale.md to log in."
    return 0
  fi

  log_info "Adding the official Tailscale apt repository for Ubuntu ${OS_VERSION_CODENAME:-}"
  log_info "Source: https://pkgs.tailscale.com/stable/ubuntu (official)"

  if is_dry_run; then
    log_dry "add Tailscale apt repo and install tailscale"
    return 0
  fi

  os_load_release
  local codename="${VERSION_CODENAME:-${OS_VERSION_CODENAME}}"
  if [[ -z "${codename}" || "${codename}" == "unknown" ]]; then
    log_warn "Could not detect Ubuntu codename; skip Tailscale package. Install later from docs/tailscale.md."
    return 0
  fi

  sudo_run mkdir -p -m 755 /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/tailscale-archive-keyring.gpg ]]; then
    curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${codename}.noarmor.gpg" \
      | sudo_run tee /etc/apt/keyrings/tailscale-archive-keyring.gpg >/dev/null
  fi
  curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${codename}.tailscale-keyring.list" \
    | sudo_run tee /etc/apt/sources.list.d/tailscale.list >/dev/null

  APT_UPDATED=0
  apt_update_once
  sudo_run apt-get install -y tailscale
  log_success "Tailscale package installed. It is NOT logged in. See docs/tailscale.md."
  state_set "TAILSCALE_APT_REPO" "1"
}

install_docker() {
  if command_exists docker; then
    log_skip "Docker is already installed ($(docker --version 2>/dev/null || true))"
    log_info "Existing Docker installation will be preserved (not replaced)."
    _docker_maybe_add_user_to_group
    state_append_list "MODULES" "docker"
    return 0
  fi

  log_info "Installing Docker Engine from Docker's official Ubuntu apt repository"
  log_info "Method: https://docs.docker.com/engine/install/ubuntu/ (not the convenience script)"
  log_warn "Members of the 'docker' group can effectively control the machine as root."

  if is_dry_run; then
    log_dry "add Docker apt repository, install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin"
    log_dry "optionally add $(id -un) to group docker (no reboot)"
    return 0
  fi

  os_load_release
  local codename="${VERSION_CODENAME:-${OS_VERSION_CODENAME}}"
  local arch
  arch="$(dpkg --print-architecture)"

  sudo_run apt-get install -y --no-install-recommends ca-certificates curl gnupg
  sudo_run mkdir -p -m 755 /etc/apt/keyrings

  if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | sudo_run gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo_run chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n' \
    "${arch}" "${codename}" \
    | sudo_run tee /etc/apt/sources.list.d/docker.list >/dev/null

  APT_UPDATED=0
  apt_update_once
  sudo_run apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if sudo_run systemctl enable --now docker; then
    log_success "Docker service enabled"
  else
    log_warn "Could not enable docker.service. Start it later with: sudo systemctl enable --now docker"
  fi

  _docker_maybe_add_user_to_group
  log_success "Docker installed. Log out and back in after group membership changes."
  log_info "This installer will not reboot the machine."
  state_append_list "MODULES" "docker"
  state_set "DOCKER_APT_REPO" "1"
}

_docker_maybe_add_user_to_group() {
  local user
  user="$(id -un)"
  if user_in_group docker "${user}"; then
    log_skip "${user} is already in the docker group"
    return 0
  fi

  log_warn "Adding ${user} to the docker group grants root-equivalent control of this machine via the Docker socket."
  log_warn "Only do this on a laptop you control. Do not do this on a shared or untrusted system."

  if [[ "${ASSUME_YES}" != "1" ]] && ! is_dry_run; then
    if ! confirm "Add ${user} to the docker group?"; then
      log_skip "docker group membership (declined). Use sudo docker ... instead."
      return 0
    fi
  fi

  sudo_run usermod -aG docker "${user}"
  log_success "Added ${user} to group docker. Group membership applies after you log out and back in."
  log_info "No reboot will be performed."
  state_set "DOCKER_GROUP_ADDED" "${user}"
}
