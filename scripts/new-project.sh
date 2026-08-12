#!/usr/bin/env bash
# Create a new project with a README, .gitignore, .env.example and language layout.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: new-project <type> <name> [parent-dir]

Types:
  generic       README, .gitignore, .env.example
  python        uv-ready Python package layout
  node          Node.js library / CLI
  web           Front-end web app (Node)
  api           HTTP API (Python FastAPI-style layout, no packages installed)
  docker        Dockerised service skeleton
  discord-bot   Discord bot skeleton (Python)
  ai            AI app skeleton (Python)
  homelab       Self-hosted / Linux server project

Examples:
  new-project python billing-api
  new-project web dashboard ~/Projects/web
EOF
}

TYPE="${1:-}"
NAME="${2:-}"
PARENT="${3:-}"

if [[ -z "${TYPE}" || -z "${NAME}" || "${TYPE}" == "-h" || "${TYPE}" == "--help" ]]; then
  usage
  exit 1
fi

if [[ "${NAME}" == *"/"* || "${NAME}" == "." || "${NAME}" == ".." ]]; then
  die "Project name must be a single directory name, not a path."
fi
if [[ ! "${NAME}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  die "Project name may only contain letters, numbers, dots, underscores and hyphens."
fi

case "${TYPE}" in
  generic) DEFAULT_PARENT="${HOME}/Projects/personal" ;;
  python|api|discord-bot) DEFAULT_PARENT="${HOME}/Projects/python" ;;
  node|web) DEFAULT_PARENT="${HOME}/Projects/web" ;;
  docker|homelab) DEFAULT_PARENT="${HOME}/Projects/homelab" ;;
  ai) DEFAULT_PARENT="${HOME}/Projects/ai" ;;
  *)
    log_error "Unknown type: ${TYPE}"
    usage
    exit 1
    ;;
esac

PARENT="${PARENT:-${DEFAULT_PARENT}}"
DEST="${PARENT}/${NAME}"
TEMPLATE_ROOT="${REPO_ROOT}/templates/${TYPE}"

if [[ -e "${DEST}" ]]; then
  die "Refusing to overwrite existing path: ${DEST}"
fi

if [[ ! -d "${TEMPLATE_ROOT}" ]]; then
  die "Missing template directory: ${TEMPLATE_ROOT}"
fi

log_info "Creating ${TYPE} project at ${DEST}"
mkdir -p "${DEST}"
cp -a "${TEMPLATE_ROOT}/." "${DEST}/"

# Rename placeholder directories (e.g. src/PROJECT_NAME) to a Python-safe name.
pkg="${NAME//-/_}"
find "${DEST}" -depth -type d -name 'PROJECT_NAME' -print0 2>/dev/null \
  | while IFS= read -r -d '' dir; do
      mv "${dir}" "$(dirname "${dir}")/${pkg}"
    done || true

# Replace the project name placeholder in copied files.
find "${DEST}" -type f \( \
    -name '*.md' -o -name '*.toml' -o -name '*.json' -o -name '*.yml' \
    -o -name '*.yaml' -o -name '*.example' -o -name '.env.example' \
    -o -name 'pyproject.toml' -o -name 'package.json' -o -name '*.py' \
    -o -name '*.js' \
  \) -exec sed -i "s/PROJECT_NAME/${pkg}/g" {} +

if [[ ! -d "${DEST}/.git" ]]; then
  git -C "${DEST}" init >/dev/null
  log_success "Initialized git repository"
fi

log_success "Created ${DEST}"
log_info "Next: cd ${DEST} && cat README.md"
if [[ -f "${DEST}/.env.example" ]]; then
  log_info "Copy .env.example to .env locally and fill in secrets. Never commit .env."
fi
