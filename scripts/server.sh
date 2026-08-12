#!/usr/bin/env bash
# Connect to hosts defined in ~/.ssh/config. No credentials are stored here.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: server [list|ssh <host>|copy-id <host>]

Reads Host entries from ~/.ssh/config and ~/.ssh/config.d/*.conf.
Does not hard-code IPs, usernames, or keys.

  server              list configured hosts
  server list         same
  server ssh NAME     ssh NAME
  server copy-id NAME ssh-copy-id NAME
EOF
}

list_hosts() {
  local files=()
  [[ -f "${HOME}/.ssh/config" ]] && files+=("${HOME}/.ssh/config")
  if [[ -d "${HOME}/.ssh/config.d" ]]; then
    local f
    for f in "${HOME}/.ssh/config.d"/*.conf; do
      [[ -f "${f}" ]] || continue
      [[ "${f}" == *.example.conf ]] && continue
      files+=("${f}")
    done
  fi
  if [[ ${#files[@]} -eq 0 ]]; then
    log_warn "No SSH config found. Copy ssh/config.example ideas into ~/.ssh/config.d/10-homeserver.conf"
    return 0
  fi
  grep -h -E '^Host ' "${files[@]}" 2>/dev/null \
    | awk '{for (i=2;i<=NF;i++) print $i}' \
    | grep -v '[*?]' \
    | grep -v '^github.com$' \
    | sort -u
}

cmd="${1:-list}"
case "${cmd}" in
  -h|--help) usage; exit 0 ;;
  list)
    log_info "Configured SSH hosts:"
    list_hosts | sed 's/^/  /'
    log_info "Connect with: server ssh <host>"
    ;;
  ssh)
    host="${2:-}"
    [[ -n "${host}" ]] || die "usage: server ssh <host>"
    exec ssh "${host}"
    ;;
  copy-id)
    host="${2:-}"
    [[ -n "${host}" ]] || die "usage: server copy-id <host>"
    exec ssh-copy-id "${host}"
    ;;
  *)
    # Convenience: `server homeserver` → ssh homeserver
    if list_hosts | grep -qx "${cmd}"; then
      exec ssh "${cmd}"
    fi
    log_error "Unknown command or host: ${cmd}"
    usage
    exit 1
    ;;
esac
