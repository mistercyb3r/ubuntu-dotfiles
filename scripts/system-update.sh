#!/usr/bin/env bash
# Safely update packages. Does not run autoremove or other destructive cleanup.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"
# shellcheck disable=SC1091
. "${_here}/../lib/os.sh"

assert_not_windows
os_load_release
os_assert_not_root
os_assert_sudo

log_info "Updating apt packages"
sudo_run apt-get update
sudo_run apt-get upgrade -y

if command_exists snap && snap version >/dev/null 2>&1; then
  log_info "Refreshing snap packages"
  sudo_run snap refresh
else
  log_skip "snap not installed"
fi

if command_exists flatpak; then
  log_info "Updating Flatpak apps"
  run flatpak update -y
else
  log_skip "flatpak not installed"
fi

if command_exists pipx; then
  log_info "Upgrading pipx packages (uv, etc.)"
  run pipx upgrade-all || log_warn "pipx upgrade-all reported a problem"
fi

if command_exists npm && [[ "${SKIP_NPM_UPDATE:-0}" != "1" ]]; then
  log_skip "npm global update skipped (this workstation avoids global npm packages)"
fi

if command_exists fwupdmgr; then
  log_info "Checking firmware updates (fwupd). Nothing is applied automatically."
  fwupdmgr get-updates 2>/dev/null || log_info "No firmware updates reported (or fwupd needs setup)"
fi

log_success "Updates finished. Destructive cleanup was not run. Use cleanup-system for that."
log_info "Reboot only if a kernel or firmware update requires it: sudo reboot"
