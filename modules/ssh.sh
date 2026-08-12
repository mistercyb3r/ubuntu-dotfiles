#!/usr/bin/env bash
# SSH client configuration. Never installs or enables openssh-server.
# Never writes private keys. Never exposes SSH to the public internet.

configure_ssh() {
  log_info "Configuring the SSH client (not a server)"

  mkdir -p "${HOME}/.ssh"
  if ! is_dry_run; then
    chmod 700 "${HOME}/.ssh"
  fi

  local example_src="${REPO_ROOT}/ssh/config.example"
  local example_dest="${HOME}/.ssh/config.ubuntu-dotfiles.example"
  install_file "${example_src}" "${example_dest}" "644"

  _ssh_ensure_include
  _ssh_maybe_create_ed25519_key
  _ssh_harden_dir_permissions

  log_info "This laptop is configured as an SSH client only."
  log_info "openssh-server is not installed or enabled by this project."
  log_info "Do not port-forward port 22 from your router to this machine."

  state_append_list "MODULES" "ssh"
}

_ssh_ensure_include() {
  local config="${HOME}/.ssh/config"
  local include_line="Include ~/.ssh/config.d/*.conf"

  if [[ ! -d "${HOME}/.ssh/config.d" ]]; then
    if is_dry_run; then
      log_dry "mkdir -p ${HOME}/.ssh/config.d"
    else
      mkdir -p "${HOME}/.ssh/config.d"
      chmod 700 "${HOME}/.ssh/config.d"
    fi
  fi

  # Drop a commented template. Name it *.example so Include *.conf does not load it.
  local template="${HOME}/.ssh/config.d/homelab.conf.example"
  if [[ ! -f "${template}" ]]; then
    install_file "${REPO_ROOT}/ssh/config.d-homelab.example.conf" "${template}" "600"
  else
    log_skip "${template} already exists"
  fi

  if [[ -f "${config}" ]] && grep -q '^Include ~/.ssh/config.d/' "${config}"; then
    log_skip "SSH config already includes config.d"
    return 0
  fi

  if [[ -f "${config}" ]]; then
    backup_file "${config}"
  fi

  if is_dry_run; then
    log_dry "prepend Include ~/.ssh/config.d/*.conf to ${config}"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  printf '%s\n\n' "${include_line}" > "${tmp}"
  if [[ -f "${config}" ]]; then
    cat "${config}" >> "${tmp}"
  fi
  mv "${tmp}" "${config}"
  chmod 600 "${config}"
  log_success "SSH config includes ${HOME}/.ssh/config.d/*.conf"
}

_ssh_maybe_create_ed25519_key() {
  local key="${HOME}/.ssh/id_ed25519"
  if [[ -f "${key}" ]]; then
    log_skip "SSH key already exists at ${key} (left untouched)"
    return 0
  fi

  log_info "No Ed25519 SSH key found. A key is needed for GitHub and Tailscale hosts."
  log_info "The private key will be written only to ${key} and will never be copied into this repository."

  if [[ "${ASSUME_YES}" != "1" ]] && ! is_dry_run; then
    if ! confirm "Generate a new Ed25519 SSH key now?"; then
      log_skip "SSH key generation (declined). See docs/github-ssh.md"
      return 0
    fi
  fi

  if is_dry_run; then
    log_dry "ssh-keygen -t ed25519 -f ${key} -C $(id -un)@$(hostname) -N ''"
    return 0
  fi

  local comment
  comment="$(id -un)@$(hostname -s 2>/dev/null || hostname)"
  # Empty passphrase is convenient on a single-user laptop; document the trade-off.
  log_warn "Generating a key with an empty passphrase. For higher security, re-run: ssh-keygen -t ed25519"
  ssh-keygen -t ed25519 -f "${key}" -C "${comment}" -N "" -q
  chmod 600 "${key}"
  chmod 644 "${key}.pub"
  log_success "Created ${key}"
  log_info "Public key (safe to add to GitHub):"
  cat "${key}.pub"
}

_ssh_harden_dir_permissions() {
  if is_dry_run; then
    log_dry "chmod 700 ~/.ssh and 600 ~/.ssh/config ~/.ssh/id_*"
    return 0
  fi
  chmod 700 "${HOME}/.ssh" 2>/dev/null || true
  [[ -f "${HOME}/.ssh/config" ]] && chmod 600 "${HOME}/.ssh/config"
  local f
  for f in "${HOME}/.ssh"/id_*; do
    [[ -e "${f}" ]] || continue
    if [[ "${f}" == *.pub ]]; then
      chmod 644 "${f}"
    else
      chmod 600 "${f}"
    fi
  done
}
