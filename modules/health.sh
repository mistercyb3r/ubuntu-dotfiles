#!/usr/bin/env bash
# Health checks after installation. Non-destructive. Failures here are warnings
# unless a required core tool is missing.

run_health_checks() {
  log_info "Running health checks"
  local failed=0

  _check_cmd git || failed=1
  _check_cmd curl || failed=1
  _check_cmd zsh || failed=1
  _check_cmd python3 || failed=1

  if [[ "${SKIP_NODE:-0}" != "1" ]]; then
    if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
      log_success "nvm: ${HOME}/.nvm"
    else
      log_warn "nvm not found at ${HOME}/.nvm"
    fi
  fi

  if [[ "${SKIP_DOCKER:-0}" != "1" ]]; then
    if command_exists docker; then
      log_success "docker: $(docker --version 2>/dev/null | head -n1)"
    else
      log_warn "docker is not on PATH"
    fi
  fi

  if command_exists starship; then
    log_success "starship: $(starship --version 2>/dev/null | head -n1)"
  else
    log_warn "starship is not on PATH"
  fi

  if command_exists fastfetch; then
    log_success "fastfetch: $(command -v fastfetch)"
  else
    log_error "fastfetch is not on PATH (greeting will be empty)"
    failed=1
  fi
  if command_exists neofetch; then
    log_warn "neofetch is installed but unused. Fastfetch is the greeting. Optional: sudo apt-get remove -y neofetch"
  fi

  if command_exists kitty; then
    log_success "kitty: $(command -v kitty)"
  else
    log_warn "kitty is not on PATH"
  fi

  if [[ -f "${HOME}/.zshrc" ]] && grep -q 'ubuntu-dotfiles' "${HOME}/.zshrc"; then
    log_success "zshrc contains the ubuntu-dotfiles block"
  else
    log_warn "~/.zshrc does not contain the ubuntu-dotfiles block"
  fi

  if git config --global --get include.path >/dev/null; then
    log_success "git include.path is set"
  else
    log_warn "git include.path is not set"
  fi

  if [[ -d "${HOME}/Projects" ]]; then
    log_success "Projects directory: ${HOME}/Projects"
  else
    log_warn "~/Projects was not created"
  fi

  _health_shell_startup || true

  if [[ "${failed}" -ne 0 ]]; then
    die "Required tools are missing after installation."
  fi
  log_success "Health checks passed"
}

_check_cmd() {
  if command_exists "$1"; then
    log_success "$1: $(command -v "$1")"
    return 0
  fi
  log_error "$1 is not installed"
  return 1
}

_health_shell_startup() {
  if ! command_exists zsh; then
    return 0
  fi
  if is_dry_run; then
    log_dry "measure zsh startup time"
    return 0
  fi
  local start end ms
  start="$(date +%s%N 2>/dev/null || true)"
  if [[ -z "${start}" ]]; then
    return 0
  fi
  zsh -lic 'exit' >/dev/null 2>&1 || true
  end="$(date +%s%N)"
  ms=$(( (end - start) / 1000000 ))
  log_info "Interactive zsh startup ≈ ${ms} ms (target: under 100 ms idle, under 400 ms on this laptop)"
  if [[ "${ms}" -gt 800 ]]; then
    log_warn "Shell startup is slower than expected. nvm is lazy-loaded; check extra ~/.zshrc content."
  fi
  log_info "After login, run: preview-terminal   and   dotfiles-health"
}
