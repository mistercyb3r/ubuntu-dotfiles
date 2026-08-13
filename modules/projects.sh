#!/usr/bin/env bash
# Create a small, useful ~/Projects layout. Never deletes existing folders.

PROJECTS_ROOT="${PROJECTS_ROOT:-${HOME}/Projects}"

PROJECT_DIRS=(
  personal
  ai
  web
  python
  homelab
  security
  games
  experiments
)

configure_projects() {
  log_info "Creating project directories under ${PROJECTS_ROOT}"

  if is_dry_run; then
    local d
    for d in "${PROJECT_DIRS[@]}"; do
      log_dry "mkdir -p ${PROJECTS_ROOT}/${d}"
    done
    state_append_list "MODULES" "projects"
    return 0
  fi

  local d
  for d in "${PROJECT_DIRS[@]}"; do
    if [[ -d "${PROJECTS_ROOT}/${d}" ]]; then
      log_skip "${PROJECTS_ROOT}/${d} exists"
    else
      mkdir -p "${PROJECTS_ROOT}/${d}"
      log_success "Created ${PROJECTS_ROOT}/${d}"
    fi
  done

  if [[ ! -f "${PROJECTS_ROOT}/README.md" ]]; then
    cat > "${PROJECTS_ROOT}/README.md" <<'EOF'
# Projects

Local working copies live here. This directory is yours; the workstation installer
never deletes it.

| Folder | Use for |
|--------|---------|
| `personal/` | Personal tools, notes, one-off repos |
| `ai/` | AI apps, agents, model-related experiments |
| `web/` | Web apps and front-end work |
| `python/` | Python libraries, CLIs, APIs |
| `homelab/` | Self-hosted and Linux server projects |
| `security/` | Labs, notes, allowed-scope security work |
| `games/` | Game projects and engines |
| `experiments/` | Throwaway spikes |

Create a new repo with:

```bash
new-project python my-app
```
EOF
    log_success "Wrote ${PROJECTS_ROOT}/README.md"
  else
    log_skip "${PROJECTS_ROOT}/README.md exists"
  fi

  state_append_list "MODULES" "projects"
  state_set "PROJECTS_ROOT" "${PROJECTS_ROOT}"
}
