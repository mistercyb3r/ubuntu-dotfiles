#!/usr/bin/env bash
# Terminal stack: Starship, Fastfetch, Ptyxis, modern CLI tools, zsh plugins.
# Decisions are documented in docs/cli-tools.md.

# Always attempted. Missing archive names are skipped by apt_install_missing.
# Fastfetch and Ptyxis are installed separately — they are required, not optional skips.
# neofetch is never listed here (legacy; not installed).
# kitty is never listed here (removed; Ptyxis is the default terminal).
TERMINAL_CORE_PACKAGES=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zoxide
  git-delta
  duf
  yq
  tealdeer
  yazi
)

# Toys / extras that do not affect the default prompt.
TERMINAL_OPTIONAL_PACKAGES=(
  cmatrix
)

install_terminal_packages() {
  log_info "Installing the 2026 terminal stack (Starship, Fastfetch, Ptyxis, CLI tools)"

  if command_exists starship; then
    log_skip "starship is already installed ($(starship --version 2>/dev/null | head -n1))"
  elif apt_package_available starship; then
    apt_install_missing starship
  else
    _install_starship_deb
  fi

  apt_install_missing "${TERMINAL_CORE_PACKAGES[@]}"
  apt_install_missing "${TERMINAL_OPTIONAL_PACKAGES[@]}"
  install_ptyxis
  install_fastfetch

  if command_exists tldr && ! command_exists tealdeer; then
    log_skip "tldr is present (tealdeer package name differs on this release)"
  fi

  state_append_list "MODULES" "terminal-packages"
}

_install_starship_deb() {
  log_info "starship is not in this Ubuntu archive; installing the official amd64 binary from GitHub"
  log_info "Source: https://github.com/starship/starship/releases (official project, not a random script)"

  if is_dry_run; then
    log_dry "download and install latest starship binary for $(uname -m)"
    return 0
  fi

  local arch
  arch="$(uname -m)"
  local asset=""
  case "${arch}" in
    x86_64|amd64) asset="starship-x86_64-unknown-linux-gnu.tar.gz" ;;
    aarch64|arm64) asset="starship-aarch64-unknown-linux-gnu.tar.gz" ;;
    *)
      log_warn "No official Starship binary mapping for ${arch}; skip Starship"
      return 0
      ;;
  esac

  local tmp
  tmp="$(mktemp -d)"
  local url="https://github.com/starship/starship/releases/latest/download/${asset}"
  log_info "Downloading ${url}"
  if ! curl -fsSL "${url}" -o "${tmp}/${asset}"; then
    rm -rf "${tmp}"
    die "Failed to download Starship. Re-run after checking network access to GitHub."
  fi
  tar -xzf "${tmp}/${asset}" -C "${tmp}"
  if [[ ! -f "${tmp}/starship" ]]; then
    rm -rf "${tmp}"
    die "Starship archive did not contain a starship binary."
  fi
  sudo_run install -m 0755 "${tmp}/starship" /usr/local/bin/starship
  rm -rf "${tmp}"
  log_success "Installed starship to /usr/local/bin/starship"
  state_set "STARSHIP_METHOD" "github-release"
}

# Required default terminal. Ubuntu 26.04 ships Ptyxis in the archive.
# Never falls back to Kitty.
install_ptyxis() {
  if command_exists ptyxis || [[ -x /usr/bin/ptyxis ]]; then
    log_skip "ptyxis is already installed ($(command -v ptyxis || echo /usr/bin/ptyxis))"
    return 0
  fi

  log_info "Installing Ptyxis (required default terminal)"

  if apt_package_available ptyxis; then
    apt_install_missing ptyxis
  else
    log_error "ptyxis is not in the enabled apt repositories."
    log_error "On Ubuntu 26.04: sudo apt-get update && sudo apt-get install -y ptyxis"
    return 1
  fi

  if command_exists ptyxis || [[ -x /usr/bin/ptyxis ]]; then
    log_success "Ptyxis: $(command -v ptyxis || echo /usr/bin/ptyxis)"
    return 0
  fi

  log_error "Ptyxis is required and could not be installed."
  log_error "On Ubuntu 26.04: sudo apt-get install -y ptyxis"
  return 1
}

# Required greeting tool. Ubuntu 26.04: universe package. Older releases: GitHub .deb.
# Never falls back to neofetch.
install_fastfetch() {
  if command_exists fastfetch; then
    log_skip "fastfetch is already installed ($(fastfetch --version 2>/dev/null | head -n1))"
    return 0
  fi

  log_info "Installing Fastfetch (required greeting; neofetch is not used)"

  if ! apt_package_available fastfetch; then
    log_info "fastfetch not visible to apt yet; enabling Ubuntu universe (26.04 ships it there)"
    ensure_ubuntu_universe
  fi

  if apt_package_available fastfetch; then
    apt_install_missing fastfetch
  else
    log_info "fastfetch is not in the enabled apt repositories; using the official GitHub .deb"
    _install_fastfetch_deb
  fi

  if command_exists fastfetch; then
    log_success "Fastfetch: $(command -v fastfetch)"
    return 0
  fi

  log_error "Fastfetch is required and could not be installed."
  log_error "On Ubuntu 26.04: sudo add-apt-repository -y universe && sudo apt-get install -y fastfetch"
  log_error "Or install the official .deb from https://github.com/fastfetch-cli/fastfetch/releases"
  return 1
}

_install_fastfetch_deb() {
  log_info "Installing Fastfetch from the official GitHub release"
  log_info "Source: https://github.com/fastfetch-cli/fastfetch/releases"

  if is_dry_run; then
    log_dry "download and dpkg-install latest fastfetch .deb for $(uname -m)"
    return 0
  fi

  local arch
  arch="$(uname -m)"
  local asset=""
  case "${arch}" in
    x86_64|amd64) asset="fastfetch-linux-amd64.deb" ;;
    aarch64|arm64) asset="fastfetch-linux-aarch64.deb" ;;
    *)
      log_warn "No official Fastfetch .deb mapping for ${arch}; skip Fastfetch"
      return 0
      ;;
  esac

  local tmp
  tmp="$(mktemp -d)"
  local url="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/${asset}"
  log_info "Downloading ${url}"
  if ! curl -fsSL "${url}" -o "${tmp}/${asset}"; then
    rm -rf "${tmp}"
    log_warn "Could not download Fastfetch. Greeting will be empty until it is installed."
    return 0
  fi
  sudo_run dpkg -i "${tmp}/${asset}" || sudo_run apt-get install -f -y
  rm -rf "${tmp}"
  if command_exists fastfetch; then
    log_success "Installed fastfetch from the official GitHub release"
    state_set "FASTFETCH_METHOD" "github-release"
  else
    log_warn "Fastfetch .deb installed but binary not on PATH"
  fi
}
