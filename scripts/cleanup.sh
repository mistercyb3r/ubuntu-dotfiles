#!/usr/bin/env bash
# Safe cleanup. Always shows what would be removed. Requires confirmation
# unless --apply is passed after a dry listing.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"
# shellcheck disable=SC1091
. "${_here}/../lib/os.sh"

APPLY=0
for arg in "$@"; do
  case "${arg}" in
    --apply) APPLY=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: cleanup-system [--apply] [--yes]

Shows apt autoremove / cache cleanup candidates. Does not delete personal
files, Projects, Git repos, Docker volumes, or SSH keys.

  (no flags)   preview only
  --apply      perform the cleanup after confirmation
  --yes        skip the confirmation prompt (still requires --apply)
EOF
      exit 0
      ;;
    *)
      log_error "Unknown option: ${arg}"
      exit 1
      ;;
  esac
done

assert_not_windows
os_assert_not_root

log_info "Preview: packages that apt would autoremove"
apt-get -s autoremove || true

echo
log_info "Preview: apt cache size"
du -sh /var/cache/apt/archives 2>/dev/null || true

echo
log_info "Preview: user cache ${XDG_CACHE_HOME:-${HOME}/.cache} (not removed automatically)"
du -sh "${XDG_CACHE_HOME:-${HOME}/.cache}" 2>/dev/null || true

if command_exists docker; then
  echo
  log_info "Docker disk usage (not pruned unless you run docker system prune yourself)"
  docker system df 2>/dev/null || log_warn "Cannot talk to the Docker daemon"
fi

if [[ "${APPLY}" != "1" ]]; then
  log_info "Preview only. Re-run with --apply to remove unused apt packages and clean the apt cache."
  log_info "This will never delete ~/Projects, Git repositories, or personal files."
  exit 0
fi

os_assert_sudo
if [[ "${ASSUME_YES}" != "1" ]] && ! confirm "Run apt autoremove and apt-get clean?"; then
  log_skip "Cleanup cancelled"
  exit 0
fi

sudo_run apt-get autoremove -y
sudo_run apt-get clean
log_success "Apt cleanup complete"
log_info "User caches, Docker images, and journal logs were left untouched."
