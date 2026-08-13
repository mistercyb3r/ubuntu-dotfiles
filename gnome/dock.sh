#!/usr/bin/env bash
# Turn Ubuntu's left side launcher into a centred bottom dock.
# Safe to run on its own after you are logged into GNOME.

set -euo pipefail
_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"
# shellcheck disable=SC1091
. "${_here}/settings.sh"

gnome_apply_dock
log_success "Dock is at the bottom. If it still looks like a side panel, log out and back in."
