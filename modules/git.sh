#!/usr/bin/env bash
# Git defaults. Never writes user.name / user.email into the repository.
# Identity is stored only in the user's ~/.gitconfig via a helper script.

configure_git() {
  log_info "Configuring Git defaults (no identity, no credentials)"

  local include_path="${REPO_ROOT}/git/gitconfig"
  if [[ ! -f "${include_path}" ]]; then
    die "Missing ${include_path}"
  fi

  if is_dry_run; then
    log_dry "git config --global include.path ${include_path}"
    log_dry "git config --global core.excludesfile ${REPO_ROOT}/config/gitignore-global"
    log_dry "git config --global init.defaultBranch main"
    state_append_list "MODULES" "git"
    return 0
  fi

  if [[ -f "${HOME}/.gitconfig" ]]; then
    backup_file "${HOME}/.gitconfig"
  fi

  git config --global include.path "${include_path}"
  git config --global core.excludesfile "${REPO_ROOT}/config/gitignore-global"
  git config --global init.defaultBranch main

  # Safer defaults that do not change identity.
  git config --global pull.rebase false
  git config --global fetch.prune true
  git config --global color.ui auto
  git config --global diff.algorithm histogram
  git config --global merge.conflictstyle zdiff3
  git config --global rerere.enabled true
  git config --global help.autocorrect 20

  if command_exists delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.dark true
    git config --global delta.line-numbers true
    git config --global delta.syntax-theme "TwoDark"
    log_success "Git pager set to delta"
  fi

  if command_exists nvim; then
    git config --global core.editor nvim
  elif command_exists vim; then
    git config --global core.editor vim
  elif command_exists nano; then
    git config --global core.editor nano
  fi

  _git_warn_if_identity_missing
  link_script "${REPO_ROOT}/scripts/setup-git-identity.sh" "setup-git-identity"
  state_append_list "MODULES" "git"
  log_success "Git defaults applied. Configure your name and email with: setup-git-identity"
}

_git_warn_if_identity_missing() {
  local name email
  name="$(git config --global --get user.name || true)"
  email="$(git config --global --get user.email || true)"
  if [[ -z "${name}" || -z "${email}" ]]; then
    log_warn "Git user.name / user.email are not set. Commits will be rejected or mis-attributed until you run:"
    log_warn "  setup-git-identity"
    log_warn "  # or: git config --global user.name \"Your Name\""
    log_warn "  #     git config --global user.email \"you@example.com\""
  else
    log_success "Git identity already set for this user (values are not stored in the repo)"
  fi
}
