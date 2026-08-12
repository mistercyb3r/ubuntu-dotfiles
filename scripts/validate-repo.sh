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
