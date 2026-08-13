#!/usr/bin/env bash
# Remove configuration created by this repository.
# Never deletes personal files, ~/Projects, Git repos, or unrelated packages.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/os.sh"

PURGE_PACKAGES=0
RESTORE_SHELL=0

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [options]

Removes configuration written by ubuntu-dotfiles. It will not:
  - delete ~/Projects or any Git repository
  - delete SSH private keys
  - delete personal files
  - uninstall Docker, Node, Python, or apt packages (unless --purge-packages)

Options:
  --dry-run           Show actions without changing anything
  --restore-shell     Also restore the previous login shell if it was recorded
  --purge-packages    Also apt-remove packages this installer added
                      (still never removes docker if it pre-existed)
  --yes, -y           Skip confirmation
  --help, -h          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --restore-shell) RESTORE_SHELL=1; shift ;;
    --purge-packages) PURGE_PACKAGES=1; shift ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

assert_not_windows
os_assert_not_root

log_warn "This will remove ubuntu-dotfiles configuration from your account."
log_info "Personal files, ~/Projects, and SSH keys will be left untouched."
log_info "Backups live in ${DOTFILES_BACKUP_ROOT}"

if [[ "${ASSUME_YES}" != "1" ]] && ! is_dry_run; then
  if ! confirm "Continue with uninstall?"; then
    log_skip "Uninstall cancelled"
    exit 0
  fi
fi

remove_marked_block "${HOME}/.zshrc"
remove_marked_block "${HOME}/.bashrc"

if [[ -f "${HOME}/.tmux.conf" ]]; then
  if grep -qE 'Prefix (remains|stays) C-b' "${HOME}/.tmux.conf" 2>/dev/null; then
    backup_file "${HOME}/.tmux.conf"
    if ! is_dry_run; then
      rm -f "${HOME}/.tmux.conf"
      log_success "Removed ~/.tmux.conf written by this repo"
    else
      log_dry "rm ${HOME}/.tmux.conf"
    fi
  else
    log_skip "~/.tmux.conf does not look like the repo copy; left in place"
  fi
fi

if [[ -f "${XDG_CONFIG_HOME}/starship.toml" ]]; then
  backup_file "${XDG_CONFIG_HOME}/starship.toml"
  if ! is_dry_run; then
    rm -f "${XDG_CONFIG_HOME}/starship.toml"
    log_success "Removed ~/.config/starship.toml"
  else
    log_dry "rm ${XDG_CONFIG_HOME}/starship.toml"
  fi
fi

if command_exists git; then
  local_include="$(git config --global --get include.path || true)"
  if [[ "${local_include}" == "${REPO_ROOT}/git/gitconfig" ]]; then
    if is_dry_run; then
      log_dry "git config --global --unset include.path"
    else
      git config --global --unset include.path || true
      log_success "Removed git include.path"
    fi
  fi
  local_excludes="$(git config --global --get core.excludesfile || true)"
  if [[ "${local_excludes}" == "${REPO_ROOT}/config/gitignore-global" ]]; then
    if is_dry_run; then
      log_dry "git config --global --unset core.excludesfile"
    else
      git config --global --unset core.excludesfile || true
    fi
  fi
  log_info "Git user.name and user.email were left unchanged."
fi

# Remove wrappers we linked into ~/.local/bin
for name in system-info system-update cleanup-system new-project server check-secrets setup-git-identity preview-terminal dotfiles-health theme-health bat fd; do
  dest="${XDG_BIN_HOME}/${name}"
  if [[ -L "${dest}" ]]; then
    target="$(readlink -f "${dest}" 2>/dev/null || true)"
    if [[ "${target}" == "${REPO_ROOT}"* ]] || [[ "${name}" == "bat" || "${name}" == "fd" ]]; then
      if is_dry_run; then
        log_dry "rm ${dest}"
      else
        rm -f "${dest}"
        log_success "Removed ${dest}"
      fi
    fi
  fi
done

if [[ -d "${DOTFILES_CONFIG_DIR}" ]]; then
  if is_dry_run; then
    log_dry "rm -rf ${DOTFILES_CONFIG_DIR}"
  else
    rm -rf "${DOTFILES_CONFIG_DIR}"
    log_success "Removed ${DOTFILES_CONFIG_DIR}"
  fi
fi

if [[ "${RESTORE_SHELL}" == "1" ]]; then
  prev="$(state_get PREVIOUS_SHELL)"
  if [[ -n "${prev}" && -x "${prev}" ]]; then
    log_info "Restoring login shell to ${prev}"
    if is_dry_run; then
      log_dry "chsh -s ${prev}"
    else
      chsh -s "${prev}" || log_warn "chsh failed"
    fi
  else
    log_skip "No previous shell recorded"
  fi
fi

if [[ "${PURGE_PACKAGES}" == "1" ]]; then
  log_warn "--purge-packages will apt-remove tools this profile commonly installs."
  log_warn "Docker is not removed automatically (it may have pre-existed)."
  if [[ "${ASSUME_YES}" != "1" ]] && ! is_dry_run; then
    if ! confirm "Remove workstation apt packages (not Docker)?"; then
      PURGE_PACKAGES=0
    fi
  fi
  if [[ "${PURGE_PACKAGES}" == "1" ]]; then
    os_assert_sudo
    sudo_run apt-get remove -y zsh starship btop eza fonts-jetbrains-mono || true
    log_info "Core OS packages (git, curl, python3, openssh-client) were left installed."
  fi
fi

log_info "Left in place on purpose:"
log_info "  - ${HOME}/Projects"
log_info "  - ${HOME}/.ssh (including keys)"
log_info "  - ${HOME}/.gitconfig identity keys"
log_info "  - ${HOME}/.nvm"
log_info "  - Docker, Tailscale, and other packages"
log_info "  - timestamped backups in ${DOTFILES_BACKUP_ROOT}"

log_success "Uninstall finished. Restore files from ${DOTFILES_BACKUP_ROOT} if needed."
