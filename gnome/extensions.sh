#!/usr/bin/env bash
# GNOME extensions policy for this workstation.
#
# This project does NOT install GNOME Shell extensions.
# Ubuntu already ships Dash to Dock (as Ubuntu Dock) and AppIndicator support.
# Extra extensions are a common source of breakage after GNOME version upgrades.

gnome_document_extensions() {
  log_info "GNOME extensions: none will be installed by this repository."
  log_info "Ubuntu Dock and AppIndicator are already part of Ubuntu Desktop."
  log_info "If you later want an extension, prefer one extension at a time and pin its version."
}

# Documented optional extensions (NOT installed):
# - Clipboard Indicator: GNOME 45+ has a built-in clipboard; skip.
# - Caffeine: use `powerprofilesctl set performance` or GNOME's built-in inhibit instead.
# - Blur my Shell / dash cosmetics: visual only, skip for stability.
# - gsconnect: useful if you pair a phone; install yourself if needed.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "${_here}/../lib/common.sh"
  gnome_document_extensions
fi
