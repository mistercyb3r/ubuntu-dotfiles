#!/usr/bin/env bash
# Lightweight secret scan for the current directory (or a path).
# This is a safety net, not a substitute for reviewing `git diff`.
set -euo pipefail

ROOT="${1:-.}"

PATTERNS=(
  'BEGIN OPENSSH PRIVATE KEY'
  'BEGIN RSA PRIVATE KEY'
  'BEGIN EC PRIVATE KEY'
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{20,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'xox[baprs]-'
  'sk-[A-Za-z0-9]{20,}'
  '-----BEGIN PRIVATE KEY-----'
)

echo "Scanning ${ROOT} for obvious secrets (not a complete audit)..."

found=0
while IFS= read -r -d '' file; do
  case "${file}" in
    *.png|*.jpg|*.jpeg|*.gif|*.woff|*.woff2|*.zip|*.gz|*.pyc) continue ;;
    *check-secrets.sh|*validate-repo.sh) continue ;;
  esac
  for pat in "${PATTERNS[@]}"; do
    if grep -E -I -n -- "${pat}" "${file}" >/dev/null 2>&1; then
      echo "POSSIBLE SECRET in ${file} (pattern: ${pat})"
      found=1
    fi
  done
done < <(find "${ROOT}" -type f \
  -not -path '*/.git/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.venv/*' \
  -not -path '*/venv/*' \
  -print0 2>/dev/null)

if [[ "${found}" -eq 1 ]]; then
  echo "Review the matches before committing. If they are real secrets, rotate them."
  exit 1
fi
echo "No obvious secret patterns found."
