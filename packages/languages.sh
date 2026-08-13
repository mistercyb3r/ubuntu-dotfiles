#!/usr/bin/env bash
# Optional extra language toolchains. Detect first. Never curl | sh.
# Enabled with ./install.sh --languages

install_optional_languages() {
  if [[ "${ENABLE_LANGUAGES:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Optional languages: install only what is missing (apt, no extra version managers)"

  if command_exists rustc && command_exists cargo; then
    log_skip "Rust already present ($(rustc --version 2>/dev/null | awk '{print $2}'))"
  else
    apt_install_missing rustc cargo
  fi

  if command_exists go; then
    log_skip "Go already present ($(go version 2>/dev/null))"
  else
    apt_install_missing golang-go
  fi

  if command_exists javac; then
    log_skip "JDK already present ($(javac -version 2>&1))"
  else
    apt_install_missing default-jdk
  fi

  state_append_list "MODULES" "languages"
}
