#!/usr/bin/env bash
# Set Git user.name and user.email for this account only.
# Values are written to ~/.gitconfig and are never stored in the repository.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"

current_name="$(git config --global --get user.name || true)"
current_email="$(git config --global --get user.email || true)"

echo "Git identity is stored in ${HOME}/.gitconfig only."
echo "This repository will never receive your name, email, or credentials."
echo

if [[ -n "${current_name}" ]]; then
  echo "Current user.name:  ${current_name}"
else
  echo "Current user.name:  (not set)"
fi
if [[ -n "${current_email}" ]]; then
  echo "Current user.email: ${current_email}"
else
  echo "Current user.email: (not set)"
fi
echo

if [[ ! -t 0 ]]; then
  log_error "This command is interactive. Run it in a terminal, or set:"
  log_error "  git config --global user.name \"Your Name\""
  log_error "  git config --global user.email \"you@example.com\""
  exit 1
fi

read -r -p "user.name  [${current_name}]: " name
read -r -p "user.email [${current_email}]: " email

name="${name:-${current_name}}"
email="${email:-${current_email}}"

if [[ -z "${name}" || -z "${email}" ]]; then
  die "Both name and email are required."
fi

if [[ "${email}" != *"@"* ]]; then
  die "That does not look like an email address."
fi

git config --global user.name "${name}"
git config --global user.email "${email}"
log_success "Saved Git identity for this user"
log_info "Verify with: git config --global --list | grep user"
