#!/usr/bin/env bash
# GNOME 50 extension policy (Ubuntu 26.04, Latitude UHD 620).
#
# This project does NOT install extensions from extensions.gnome.org.
# Ubuntu already ships and maintains:
#   - Ubuntu Dock (dash-to-dock fork) — configured in gnome/settings.sh
#   - AppIndicator / KStatusNotifierItem
#   - Desktop Icons NG (left at Ubuntu defaults)
#
# Research (2026-08):
# - Blur my Shell 72 claims GNOME 50 support, but it conflicts with Ubuntu Dock
#   overview highlighting and costs GPU time on Intel UHD 620. Not installed.
# - Dash to Dock 105 supports GNOME 50; Ubuntu Dock is the packaged equivalent.
# - Clipboard Indicator is redundant: GNOME 50 has a built-in clipboard.
# - Vitals / system-monitor extensions keep sensors polling. Skip for battery.
# - Extra dock animation companions add Shell hooks we do not need.
#
# Extension Manager is installed with the look profile so you can add ONE
# extension yourself if you accept the upgrade risk.

gnome_document_extensions() {
  log_info "GNOME extensions: only Ubuntu-shipped Dock + AppIndicator are used."
  log_info "Blur my Shell is not installed (UHD 620 + Ubuntu Dock conflict)."
  log_info "Extension Manager is available if you want one extra extension later."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "${_here}/../lib/common.sh"
  gnome_document_extensions
fi
