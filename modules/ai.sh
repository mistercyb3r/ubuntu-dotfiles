#!/usr/bin/env bash
# Optional AI directories and env. No models downloaded. No CUDA on Intel.

configure_ai() {
  if [[ "${ENABLE_AI:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Preparing local AI directories (no model downloads)"

  local share="${XDG_DATA_HOME:-${HOME}/.local/share}/ubuntu-dotfiles/ai"
  local cache="${XDG_CACHE_HOME:-${HOME}/.cache}/ubuntu-dotfiles/ai"
  mkdir -p "${share}/models" "${share}/projects" "${cache}" \
    "${PROJECTS_ROOT:-${HOME}/Projects}/ai"

  if is_dry_run; then
    log_dry "write ${DOTFILES_CONFIG_DIR}/ai.env"
    state_append_list "MODULES" "ai"
    return 0
  fi

  mkdir -p "${DOTFILES_CONFIG_DIR}"
  cat > "${DOTFILES_CONFIG_DIR}/ai.env" <<EOF
# Written by ubuntu-dotfiles --ai. Sourced from the zsh marked block when present.
# No secrets. No automatic model pulls.
export UDF_AI_HOME="${share}"
export UDF_AI_CACHE="${cache}"
export OLLAMA_MODELS="${share}/models"
export HF_HOME="${cache}/huggingface"
EOF

  log_success "AI dirs: ${share} and ${cache}"
  log_info "Ollama models (if you install ollama later) go in ${share}/models"
  if [[ "${UDF_GPU_VENDOR:-}" == "intel" || "${UDF_GPU_VENDOR:-}" == "unknown" ]]; then
    log_info "Latitude iGPU: use CPU Ollama models. Do not install CUDA."
  fi
  state_append_list "MODULES" "ai"
}
