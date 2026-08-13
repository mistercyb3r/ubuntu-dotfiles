#!/usr/bin/env bash
# Static checks for this repository. Does not install packages or change the system.
# Safe on Git Bash (Windows) and Ubuntu. Not a substitute for ./install.sh --dry-run on Ubuntu.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

echo "Checking shell syntax..."
while IFS= read -r -d '' file; do
  if ! bash -n "${file}"; then
    echo "SYNTAX FAIL: ${file}"
    fail=1
  fi
done < <(find "${ROOT}" -name '*.sh' -type f -print0)

echo "Checking scripts for hard-coded /home/user paths..."
if grep -R -n -E '/home/[A-Za-z0-9._-]+' --include='*.sh' "${ROOT}" \
  | grep -v 'validate-repo.sh'; then
  echo "FAIL: hard-coded home directory in a script"
  fail=1
else
  echo "No hard-coded home paths in scripts."
fi

echo "Checking state_get does not abort under set -euo pipefail when a key is missing..."
_state_test_dir="$(mktemp -d)"
if ! bash -euo pipefail -c "
  # shellcheck disable=SC1091
  . \"${ROOT}/lib/common.sh\"
  DOTFILES_STATE_DIR=\"${_state_test_dir}\"
  DOTFILES_CONFIG_DIR=\"${_state_test_dir}/config\"
  DOTFILES_BACKUP_ROOT=\"${_state_test_dir}/backups\"
  DOTFILES_LOG_DIR=\"${_state_test_dir}/logs\"
  DOTFILES_STATE_FILE=\"${_state_test_dir}/state\"
  XDG_BIN_HOME=\"${_state_test_dir}/bin\"
  DRY_RUN=0
  mkdir -p \"\${DOTFILES_STATE_DIR}\"
  : > \"\${DOTFILES_STATE_FILE}\"
  val=\"\$(state_get MODULES)\"
  [[ -z \"\${val}\" ]]
  state_append_list MODULES apt
  val=\"\$(state_get MODULES)\"
  [[ \"\${val}\" == apt ]]
  state_append_list MODULES apt
  val=\"\$(state_get MODULES)\"
  [[ \"\${val}\" == apt ]]
  state_append_list MODULES shell
  val=\"\$(state_get MODULES)\"
  [[ \"\${val}\" == 'apt shell' ]]
"; then
  echo "FAIL: state_get/state_append_list aborted or returned the wrong value under pipefail"
  fail=1
else
  echo "state_get pipefail regression: OK"
fi
rm -rf "${_state_test_dir}"

echo "Checking installer kill usage is namespaced and never targets \$\$..."
if grep -RIn --include='*.sh' -E 'kill[[:space:]]+(\$\$|\$PPID|\$\{?PPID|\$\{?\$)' "${ROOT}" \
  | grep -v 'validate-repo.sh'; then
  echo "FAIL: unsafe kill of installer or parent PID"
  fail=1
else
  echo "No kill \$\$ / \$PPID in scripts."
fi
if grep -RIn --include='*.sh' -E "^[[:space:]]*trap .*kill" "${ROOT}"; then
  echo "FAIL: raw kill still used in an EXIT trap"
  fail=1
else
  echo "sudo keepalive trap uses the safe helper."
fi

echo "Checking Fastfetch 2.57 display keys in terminal/fastfetch.jsonc..."
_ff_cfg="${ROOT}/terminal/fastfetch.jsonc"
if [[ ! -f "${_ff_cfg}" ]]; then
  echo "FAIL: missing ${_ff_cfg}"
  fail=1
elif grep -E '^[[:space:]]*"keyWidth"' "${_ff_cfg}"; then
  echo "FAIL: display.keyWidth is not valid in Fastfetch 2.57.1 (use display.key.width)"
  fail=1
else
  echo "No unsupported top-level display.keyWidth."
fi
if command -v fastfetch >/dev/null 2>&1; then
  _ff_out=""
  set +e
  _ff_out="$(fastfetch --config "${_ff_cfg}" 2>&1)"
  _ff_rc=$?
  set -e
  if printf '%s\n' "${_ff_out}" | grep -qi 'JsonConfig Error'; then
    echo "FAIL: fastfetch --config reported JsonConfig Error"
    printf '%s\n' "${_ff_out}"
    fail=1
  elif [[ "${_ff_rc}" -ne 0 ]]; then
    echo "WARN: fastfetch --config exited ${_ff_rc} (no JsonConfig Error)"
  else
    echo "fastfetch --config ${_ff_cfg}: OK"
  fi
  unset _ff_out _ff_rc
else
  echo "fastfetch not installed here; skipped live config parse (run on Ubuntu 26.04)"
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "Running shellcheck..."
  # SC1091: sourced files use runtime paths; SC1090: dynamic source in install.sh
  shellcheck -x -e SC1090,SC1091 \
    "${ROOT}/install.sh" "${ROOT}/uninstall.sh" \
    "${ROOT}/lib/"*.sh "${ROOT}/scripts/"*.sh \
    "${ROOT}/bootstrap/"*.sh "${ROOT}/packages/"*.sh "${ROOT}/modules/"*.sh \
    "${ROOT}/gnome/"*.sh || fail=1
else
  echo "shellcheck not installed (optional; apt install shellcheck on Ubuntu)"
fi

if [[ "${fail}" -ne 0 ]]; then
  echo "Validation failed."
  exit 1
fi
echo "Validation passed."
