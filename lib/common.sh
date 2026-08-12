#!/usr/bin/env bash
# Shared helpers for the Ubuntu developer-workstation installer.
# Safe to source from install.sh, uninstall.sh, and standalone scripts.

# Prevent double-sourcing
if [[ -n "${UBUNTU_DOTFILES_COMMON_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
UBUNTU_DOTFILES_COMMON_LOADED=1

DOTFILES_VERSION="1.0.0"
DOTFILES_NAME="ubuntu-dotfiles"
DOTFILES_MARKER_BEGIN="# >>> ubuntu-dotfiles >>>"
DOTFILES_MARKER_END="# <<< ubuntu-dotfiles <<<"

# ---------------------------------------------------------------------------
# Paths (never hard-code a username or hostname)
# ---------------------------------------------------------------------------

_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${_lib_dir}/.." && pwd)"
unset _lib_dir

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
XDG_BIN_HOME="${HOME}/.local/bin"

DOTFILES_STATE_DIR="${XDG_DATA_HOME}/${DOTFILES_NAME}"
DOTFILES_CONFIG_DIR="${XDG_CONFIG_HOME}/${DOTFILES_NAME}"
DOTFILES_BACKUP_ROOT="${DOTFILES_STATE_DIR}/backups"
DOTFILES_STATE_FILE="${DOTFILES_STATE_DIR}/state"
DOTFILES_REPO_PATH_FILE="${DOTFILES_STATE_DIR}/repo-path"
DOTFILES_LOG_DIR="${DOTFILES_STATE_DIR}/logs"

# Set by install.sh; default to live (non-dry-run) for standalone scripts.
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"
INSTALL_PROFILE="${INSTALL_PROFILE:-full}"

# ---------------------------------------------------------------------------
# Terminal output
# ---------------------------------------------------------------------------

_is_tty() {
  [[ -t 1 ]]
}

if _is_tty && [[ -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_CYAN=$'\033[36m'
else
  C_RESET="" C_BOLD="" C_DIM="" C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_CYAN=""
fi

log_info()    { printf '%s[info]%s %s\n'    "${C_BLUE}"   "${C_RESET}" "$*"; }
log_success() { printf '%s[ok]%s   %s\n'    "${C_GREEN}"  "${C_RESET}" "$*"; }
log_warn()    { printf '%s[warn]%s %s\n'    "${C_YELLOW}" "${C_RESET}" "$*" >&2; }
log_error()   { printf '%s[error]%s %s\n'   "${C_RED}"    "${C_RESET}" "$*" >&2; }
log_skip()    { printf '%s[skip]%s %s\n'    "${C_DIM}"    "${C_RESET}" "$*"; }
log_dry()     { printf '%s[dry-run]%s %s\n' "${C_CYAN}"   "${C_RESET}" "$*"; }

log_step() {
  local current="$1"
  local total="$2"
  local title="$3"
  printf '\n%s[%s/%s]%s %s%s%s\n' \
    "${C_BOLD}${C_CYAN}" "${current}" "${total}" "${C_RESET}" \
    "${C_BOLD}" "${title}" "${C_RESET}"
}

die() {
  log_error "$*"
  log_error "A critical step failed. The installer stopped to avoid leaving the system in a bad state."
  exit 1
}

# ---------------------------------------------------------------------------
# Dry-run / command execution
# ---------------------------------------------------------------------------

is_dry_run() {
  [[ "${DRY_RUN}" == "1" ]]
}

# Run a command, or print it during --dry-run.
# Usage: run command arg...
run() {
  if is_dry_run; then
    log_dry "$*"
    return 0
  fi
  "$@"
}

# Run a command with sudo when not already root.
sudo_run() {
  if is_dry_run; then
    if [[ "${EUID}" -eq 0 ]]; then
      log_dry "$*"
    else
      log_dry "sudo $*"
    fi
    return 0
  fi
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------

confirm() {
  local prompt="${1:-Continue?}"
  if [[ "${ASSUME_YES}" == "1" ]]; then
    return 0
  fi
  if is_dry_run; then
    log_dry "Would prompt: ${prompt} [y/N]"
    return 0
  fi
  if ! [[ -t 0 ]]; then
    return 1
  fi
  local reply
  read -r -p "${prompt} [y/N] " reply
  [[ "${reply}" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# ---------------------------------------------------------------------------
# Detection helpers
# ---------------------------------------------------------------------------

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_linux() {
  [[ "$(uname -s 2>/dev/null)" == "Linux" ]]
}

is_windows_shell() {
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*|Windows_NT) return 0 ;;
  esac
  [[ -n "${WINDIR:-}" && ! -f /etc/os-release ]]
}

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

package_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'
}

apt_package_available() {
  apt-cache show "$1" >/dev/null 2>&1
}

user_in_group() {
  local group="$1"
  local user="${2:-$(id -un)}"
  id -nG "${user}" 2>/dev/null | tr ' ' '\n' | grep -qx "${group}"
}

file_contains() {
  local file="$1"
  local needle="$2"
  [[ -f "${file}" ]] && grep -F -q -- "${needle}" "${file}"
}

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

ensure_state_dirs() {
  if is_dry_run; then
    log_dry "mkdir -p ${DOTFILES_STATE_DIR} ${DOTFILES_CONFIG_DIR} ${DOTFILES_BACKUP_ROOT} ${DOTFILES_LOG_DIR} ${XDG_BIN_HOME}"
    return 0
  fi
  mkdir -p "${DOTFILES_STATE_DIR}" "${DOTFILES_CONFIG_DIR}" \
    "${DOTFILES_BACKUP_ROOT}" "${DOTFILES_LOG_DIR}" "${XDG_BIN_HOME}"
}

state_set() {
  local key="$1"
  local value="$2"
  if is_dry_run; then
    log_dry "state ${key}=${value}"
    return 0
  fi
  ensure_state_dirs
  touch "${DOTFILES_STATE_FILE}"
  local tmp
  tmp="$(mktemp)"
  if [[ -f "${DOTFILES_STATE_FILE}" ]]; then
    grep -v "^${key}=" "${DOTFILES_STATE_FILE}" > "${tmp}" || true
  fi
  printf '%s=%s\n' "${key}" "${value}" >> "${tmp}"
  mv "${tmp}" "${DOTFILES_STATE_FILE}"
}

state_get() {
  local key="$1"
  [[ -f "${DOTFILES_STATE_FILE}" ]] || return 0
  grep "^${key}=" "${DOTFILES_STATE_FILE}" 2>/dev/null | tail -n1 | cut -d= -f2-
}

state_append_list() {
  local key="$1"
  local item="$2"
  local current
  current="$(state_get "${key}")"
  if [[ " ${current} " == *" ${item} "* ]]; then
    return 0
  fi
  if [[ -z "${current}" ]]; then
    state_set "${key}" "${item}"
  else
    state_set "${key}" "${current} ${item}"
  fi
}

save_repo_path() {
  if is_dry_run; then
    log_dry "record repo path ${REPO_ROOT}"
    return 0
  fi
  ensure_state_dirs
  printf '%s\n' "${REPO_ROOT}" > "${DOTFILES_REPO_PATH_FILE}"
  state_set "REPO_ROOT" "${REPO_ROOT}"
  state_set "VERSION" "${DOTFILES_VERSION}"
}

resolve_repo_root() {
  if [[ -n "${REPO_ROOT:-}" && -f "${REPO_ROOT}/install.sh" ]]; then
    return 0
  fi
  if [[ -f "${DOTFILES_REPO_PATH_FILE}" ]]; then
    local recorded
    recorded="$(tr -d '\r' < "${DOTFILES_REPO_PATH_FILE}")"
    if [[ -f "${recorded}/install.sh" ]]; then
      REPO_ROOT="${recorded}"
      return 0
    fi
  fi
  log_error "Could not locate the ubuntu-dotfiles repository."
  log_error "Clone it again and run install.sh, or restore ${DOTFILES_REPO_PATH_FILE}."
  return 1
}

# ---------------------------------------------------------------------------
# Backups
# ---------------------------------------------------------------------------

# Backup a file before modifying it. Copies to a timestamped directory.
# Usage: backup_file /path/to/file
backup_file() {
  local src="$1"
  if [[ ! -e "${src}" ]]; then
    return 0
  fi
  local stamp="${BACKUP_STAMP:-$(date +%Y%m%d-%H%M%S)}"
  BACKUP_STAMP="${stamp}"
  local dest_dir="${DOTFILES_BACKUP_ROOT}/${stamp}"
  local rel="${src#${HOME}/}"
  local dest="${dest_dir}/${rel}"

  if is_dry_run; then
    log_dry "backup ${src} -> ${dest}"
    return 0
  fi
  mkdir -p "$(dirname "${dest}")"
  if [[ -d "${src}" && ! -L "${src}" ]]; then
    cp -a "${src}" "${dest}"
  else
    cp -a "${src}" "${dest}"
  fi
  log_info "Backed up ${src} -> ${dest}"
  state_set "LAST_BACKUP" "${dest_dir}"
}

# ---------------------------------------------------------------------------
# File helpers
# ---------------------------------------------------------------------------

# Write a file, backing up an existing one. Does not overwrite if contents match.
write_file() {
  local dest="$1"
  local content="$2"
  if [[ -f "${dest}" ]] && printf '%s' "${content}" | cmp -s - "${dest}"; then
    log_skip "${dest} already up to date"
    return 0
  fi
  if [[ -e "${dest}" ]]; then
    backup_file "${dest}"
  fi
  if is_dry_run; then
    log_dry "write ${dest}"
    return 0
  fi
  mkdir -p "$(dirname "${dest}")"
  printf '%s' "${content}" > "${dest}"
  log_success "Wrote ${dest}"
}

# Copy a repo file into place with backup. Idempotent.
install_file() {
  local src="$1"
  local dest="$2"
  local mode="${3:-}"
  if [[ ! -f "${src}" ]]; then
    die "Missing source file: ${src}"
  fi
  if [[ -f "${dest}" ]] && cmp -s "${src}" "${dest}"; then
    log_skip "${dest} already matches ${src}"
    return 0
  fi
  if [[ -e "${dest}" ]]; then
    backup_file "${dest}"
  fi
  if is_dry_run; then
    log_dry "install ${src} -> ${dest}"
    return 0
  fi
  mkdir -p "$(dirname "${dest}")"
  cp "${src}" "${dest}"
  if [[ -n "${mode}" ]]; then
    chmod "${mode}" "${dest}"
  fi
  log_success "Installed ${dest}"
}

# Append a marked block to a file, replacing a previous block if present.
# Never deletes the rest of the file.
upsert_marked_block() {
  local file="$1"
  local block="$2"
  local begin="${DOTFILES_MARKER_BEGIN}"
  local end="${DOTFILES_MARKER_END}"

  if [[ -f "${file}" ]] && grep -F -q "${begin}" "${file}"; then
    if is_dry_run; then
      log_dry "refresh marked block in ${file}"
      return 0
    fi
    backup_file "${file}"
    local tmp
    tmp="$(mktemp)"
    awk -v begin="${begin}" -v end="${end}" '
      $0 == begin {skip=1; next}
      $0 == end {skip=0; next}
      !skip {print}
    ' "${file}" > "${tmp}"
    printf '\n%s\n%s\n%s\n' "${begin}" "${block}" "${end}" >> "${tmp}"
    mv "${tmp}" "${file}"
    log_success "Updated managed block in ${file}"
    return 0
  fi

  if [[ -e "${file}" ]]; then
    backup_file "${file}"
  fi
  if is_dry_run; then
    log_dry "append marked block to ${file}"
    return 0
  fi
  mkdir -p "$(dirname "${file}")"
  touch "${file}"
  printf '\n%s\n%s\n%s\n' "${begin}" "${block}" "${end}" >> "${file}"
  log_success "Added managed block to ${file}"
}

remove_marked_block() {
  local file="$1"
  local begin="${DOTFILES_MARKER_BEGIN}"
  local end="${DOTFILES_MARKER_END}"
  if [[ ! -f "${file}" ]] || ! grep -F -q "${begin}" "${file}"; then
    return 0
  fi
  backup_file "${file}"
  if is_dry_run; then
    log_dry "remove marked block from ${file}"
    return 0
  fi
  local tmp
  tmp="$(mktemp)"
  awk -v begin="${begin}" -v end="${end}" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "${file}" > "${tmp}"
  mv "${tmp}" "${file}"
  log_success "Removed managed block from ${file}"
}

# ---------------------------------------------------------------------------
# APT
# ---------------------------------------------------------------------------

apt_update_once() {
  if [[ "${APT_UPDATED:-0}" == "1" ]]; then
    return 0
  fi
  log_info "Updating apt package lists"
  sudo_run apt-get update
  APT_UPDATED=1
}

# Install packages that are not already present. Skips unavailable names.
# Usage: apt_install_missing pkg1 pkg2 ...
apt_install_missing() {
  local pkg
  local to_install=()
  local missing_repo=()

  for pkg in "$@"; do
    if package_installed "${pkg}"; then
      log_skip "${pkg} is already installed"
      continue
    fi
    if ! apt_package_available "${pkg}"; then
      missing_repo+=("${pkg}")
      continue
    fi
    to_install+=("${pkg}")
  done

  if [[ ${#missing_repo[@]} -gt 0 ]]; then
    log_warn "Not in this Ubuntu release's repositories (skipped): ${missing_repo[*]}"
  fi

  if [[ ${#to_install[@]} -eq 0 ]]; then
    return 0
  fi

  apt_update_once
  log_info "Installing: ${to_install[*]}"
  sudo_run apt-get install -y --no-install-recommends "${to_install[@]}"
}

# ---------------------------------------------------------------------------
# PATH / wrappers
# ---------------------------------------------------------------------------

ensure_local_bin_on_path() {
  mkdir -p "${XDG_BIN_HOME}" 2>/dev/null || true
}

link_script() {
  local src="$1"
  local name="$2"
  local dest="${XDG_BIN_HOME}/${name}"
  if [[ ! -f "${src}" ]]; then
    die "Missing script: ${src}"
  fi
  if [[ -L "${dest}" ]]; then
    local current
    current="$(readlink -f "${dest}" 2>/dev/null || true)"
    local target
    target="$(readlink -f "${src}" 2>/dev/null || true)"
    if [[ "${current}" == "${target}" ]]; then
      log_skip "${dest} already linked"
      return 0
    fi
  fi
  if [[ -e "${dest}" && ! -L "${dest}" ]]; then
    backup_file "${dest}"
  fi
  if is_dry_run; then
    log_dry "ln -sfn ${src} ${dest}"
    return 0
  fi
  mkdir -p "${XDG_BIN_HOME}"
  ln -sfn "${src}" "${dest}"
  chmod +x "${src}"
  log_success "Linked ${dest}"
}

# ---------------------------------------------------------------------------
# Safety: refuse to run the installer on Windows
# ---------------------------------------------------------------------------

assert_not_windows() {
  if is_windows_shell; then
    log_error "This installer is for Ubuntu Linux. It must not be run on Windows."
    log_error "Copy or clone this repository onto the Latitude 5400 and run it there."
    exit 1
  fi
}

assert_unix_line_endings() {
  local probe="${REPO_ROOT}/install.sh"
  if grep -q $'\r' "${probe}" 2>/dev/null; then
    die "This checkout has Windows CRLF line endings. On the laptop run: git clone <url>  (do not copy a Windows working tree). Or: sudo apt-get install -y dos2unix && dos2unix install.sh lib/*.sh"
  fi
}

require_command() {
  local cmd="$1"
  command_exists "${cmd}" || die "Required command not found: ${cmd}"
}
