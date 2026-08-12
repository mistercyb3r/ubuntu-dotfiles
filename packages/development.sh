#!/usr/bin/env bash
# Development language tooling: Python (pipx/uv) and Node.js (nvm + LTS).
# Never uses `sudo pip`. Never installs random global npm packages.

NVM_VERSION="${NVM_VERSION:-v0.40.6}"
NVM_DIR_DEFAULT="${HOME}/.nvm"

install_development_packages() {
  if [[ "${SKIP_PYTHON:-0}" != "1" ]]; then
    install_python_tooling
  else
    log_skip "Python tooling (--no-python)"
  fi

  if [[ "${SKIP_NODE:-0}" != "1" ]]; then
    install_node_tooling
  else
    log_skip "Node.js tooling (--no-node)"
  fi

  install_github_cli
  state_append_list "MODULES" "development"
}

install_python_tooling() {
  log_info "Configuring Python 3, pipx and uv"

  apt_install_missing python3 python3-venv python3-pip python3-dev pipx

  if is_dry_run; then
    log_dry "pipx ensurepath && pipx install uv"
    return 0
  fi

  # pipx is user-level. ensurepath updates the user's login PATH.
  if command_exists pipx; then
    pipx ensurepath >/dev/null 2>&1 || true
  fi

  export PATH="${HOME}/.local/bin:${PATH}"

  if command_exists uv; then
    log_skip "uv is already installed ($(uv --version 2>/dev/null || true))"
  else
    log_info "Installing uv with pipx (user-level, no sudo pip)"
    if ! pipx install uv; then
      die "pipx failed to install uv. See docs/python.md."
    fi
    log_success "Installed uv via pipx"
  fi

  state_append_list "MODULES" "python"
}

install_node_tooling() {
  log_info "Configuring nvm and Node.js LTS"

  local nvm_dir="${NVM_DIR:-${NVM_DIR_DEFAULT}}"

  if [[ -s "${nvm_dir}/nvm.sh" ]]; then
    log_skip "nvm already present at ${nvm_dir}"
  else
    _install_nvm "${nvm_dir}"
  fi

  if is_dry_run; then
    log_dry "source nvm && nvm install --lts && nvm alias default 'lts/*'"
    return 0
  fi

  # shellcheck disable=SC1091
  . "${nvm_dir}/nvm.sh"

  if command_exists node; then
    log_skip "node is already available ($(node --version 2>/dev/null || true))"
  else
    log_info "Installing the current Node.js LTS via nvm"
    nvm install --lts
    nvm alias default 'lts/*'
    log_success "Installed Node.js LTS ($(node --version 2>/dev/null || true))"
  fi

  state_append_list "MODULES" "node"
  state_set "NVM_DIR" "${nvm_dir}"
}

_install_nvm() {
  local nvm_dir="$1"
  log_info "Installing nvm ${NVM_VERSION} from the official GitHub repository"
  log_info "Method: git clone of https://github.com/nvm-sh/nvm (tagged release, not curl | bash)"

  if is_dry_run; then
    log_dry "git clone --branch ${NVM_VERSION} https://github.com/nvm-sh/nvm.git ${nvm_dir}"
    return 0
  fi

  if [[ -d "${nvm_dir}/.git" ]]; then
    git -C "${nvm_dir}" fetch --tags --depth 1 origin "${NVM_VERSION}"
    git -C "${nvm_dir}" checkout "${NVM_VERSION}"
  else
    mkdir -p "$(dirname "${nvm_dir}")"
    git clone --depth 1 --branch "${NVM_VERSION}" https://github.com/nvm-sh/nvm.git "${nvm_dir}"
  fi
  log_success "nvm ${NVM_VERSION} installed at ${nvm_dir}"
}

install_github_cli() {
  if command_exists gh; then
    log_skip "GitHub CLI already installed ($(gh --version 2>/dev/null | head -n1))"
    return 0
  fi

  if apt_package_available gh; then
    apt_install_missing gh
    return 0
  fi

  log_info "gh is not in this Ubuntu archive; adding the official GitHub CLI apt repository"
  log_info "Repository: https://cli.github.com/packages (official, signed keyring)"

  if is_dry_run; then
    log_dry "add GitHub CLI apt source and install gh"
    return 0
  fi

  sudo_run mkdir -p -m 755 /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo_run dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg status=none
    sudo_run chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  fi

  local arch
  arch="$(dpkg --print-architecture)"
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "${arch}" \
    | sudo_run tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  APT_UPDATED=0
  apt_update_once
  sudo_run apt-get install -y gh
  log_success "Installed GitHub CLI from the official apt repository"
  state_set "GH_APT_REPO" "1"
}
