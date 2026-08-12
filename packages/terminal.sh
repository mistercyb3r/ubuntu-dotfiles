#!/usr/bin/env bash
# Terminal packages: zsh (already in apt.sh), starship, extra CLI quality-of-life.
# Starship: prefer the Ubuntu package; fall back to the official GitHub .deb.

install_terminal_packages() {
  log_info "Installing terminal packages"

  if command_exists starship; then
    log_skip "starship is already installed ($(starship --version 2>/dev/null | head -n1))"
  elif apt_package_available starship; then
    apt_install_missing starship
  else
    _install_starship_deb
  fi

  state_append_list "MODULES" "terminal-packages"
}

_install_starship_deb() {
  log_info "starship is not in this Ubuntu archive; installing the official amd64 .deb from GitHub"
  log_info "Source: https://github.com/starship/starship/releases (official project, not a random script)"

  if is_dry_run; then
    log_dry "download and dpkg-install latest starship .deb for $(uname -m)"
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
