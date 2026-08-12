#!/usr/bin/env bash
# Ubuntu / Debian detection and hardware-aware helpers.
# Sourced after lib/common.sh.

os_load_release() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION_ID="${VERSION_ID:-unknown}"
    OS_VERSION_CODENAME="${VERSION_CODENAME:-unknown}"
    OS_PRETTY="${PRETTY_NAME:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
  else
    OS_ID="unknown"
    OS_VERSION_ID="unknown"
    OS_VERSION_CODENAME="unknown"
    OS_PRETTY="unknown"
    OS_ID_LIKE=""
  fi
}

os_is_ubuntu() {
  [[ "${OS_ID}" == "ubuntu" ]]
}

os_is_debian_like() {
  [[ "${OS_ID}" == "ubuntu" || "${OS_ID}" == "debian" || "${OS_ID_LIKE}" == *debian* ]]
}

os_is_supported_ubuntu() {
  case "${OS_VERSION_ID}" in
    22.04|24.04|24.10|25.04|25.10|26.04) return 0 ;;
    *) return 1 ;;
  esac
}

os_assert_compatible() {
  os_load_release

  if ! is_linux; then
    die "This project only supports Linux. Detected: $(uname -s 2>/dev/null || echo unknown)"
  fi

  if is_wsl; then
    log_warn "WSL detected. This configuration targets a Dell Latitude 5400 running Ubuntu natively."
    log_warn "GNOME, power management, zram and some hardware settings will not apply correctly in WSL."
    if [[ "${ASSUME_YES}" != "1" ]] && ! confirm "Continue anyway?"; then
      die "Aborted on WSL."
    fi
  fi

  if ! os_is_debian_like; then
    die "Unsupported OS (${OS_PRETTY}). This installer supports Ubuntu 22.04/24.04 LTS (Debian-based)."
  fi

  if ! os_is_ubuntu; then
    log_warn "Detected ${OS_PRETTY}, not Ubuntu. Packages and GNOME keys may differ."
    if [[ "${ASSUME_YES}" != "1" ]] && ! confirm "Continue on ${OS_PRETTY}?"; then
      die "Aborted."
    fi
  elif ! os_is_supported_ubuntu; then
    log_warn "Ubuntu ${OS_VERSION_ID} is not in the tested set (22.04 and 24.04 LTS)."
    if [[ "${ASSUME_YES}" != "1" ]] && ! confirm "Continue on Ubuntu ${OS_VERSION_ID}?"; then
      die "Aborted."
    fi
  fi

  log_success "OS: ${OS_PRETTY}"
}

os_assert_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    die "Do not run this installer as root. Run it as your normal user; it will sudo only when needed."
  fi
}

os_assert_sudo() {
  if is_dry_run; then
    log_dry "would verify sudo access"
    return 0
  fi
  if ! command_exists sudo; then
    die "sudo is required but was not found."
  fi
  if ! sudo -v; then
    die "Could not obtain sudo credentials. The installer needs them for package installation."
  fi
  # Keep sudo alive during a long install.
  if [[ -z "${SUDO_KEEPALIVE_PID:-}" ]]; then
    ( while true; do sleep 60; sudo -n true || exit; done ) 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT
  fi
}

os_has_gnome() {
  case "${XDG_CURRENT_DESKTOP:-}" in
    *GNOME*|*ubuntu*|*Ubuntu*) return 0 ;;
  esac
  command_exists gnome-shell
}

os_is_laptop() {
  [[ -d /sys/class/power_supply ]] || return 1
  local bat
  for bat in /sys/class/power_supply/BAT*; do
    [[ -e "${bat}" ]] && return 0
  done
  return 1
}

os_has_ssd() {
  local disk rot
  for disk in /sys/block/nvme* /sys/block/sd*; do
    [[ -e "${disk}/queue/rotational" ]] || continue
    rot="$(cat "${disk}/queue/rotational" 2>/dev/null || echo 1)"
    if [[ "${rot}" == "0" ]]; then
      return 0
    fi
  done
  return 1
}

os_cpu_vendor() {
  grep -m1 'vendor_id' /proc/cpuinfo 2>/dev/null | awk '{print $3}'
}

os_print_summary() {
  os_load_release
  log_info "User:        $(id -un)"
  log_info "Home:        ${HOME}"
  log_info "Host:        $(hostname 2>/dev/null || echo unknown)"
  log_info "OS:          ${OS_PRETTY:-unknown}"
  log_info "Kernel:      $(uname -r 2>/dev/null || echo unknown)"
  log_info "Arch:        $(uname -m 2>/dev/null || echo unknown)"
  log_info "CPU vendor:  $(os_cpu_vendor || echo unknown)"
  if os_is_laptop; then
    log_info "Chassis:     laptop (battery detected)"
  else
    log_info "Chassis:     no battery detected"
  fi
}
