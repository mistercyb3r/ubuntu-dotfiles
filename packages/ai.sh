#!/usr/bin/env bash
# Optional local AI workstation prep. Detect hardware. Never install CUDA on Intel.
# Enabled with ./install.sh --ai
# Never runs curl | sh. Never runs ollama pull.

install_ai_packages() {
  if [[ "${ENABLE_AI:-0}" != "1" ]]; then
    return 0
  fi

  log_info "AI module: hardware-aware prep (no NVIDIA stack on Intel iGPU)"
  _ai_detect_gpu

  if [[ "${UDF_GPU_VENDOR:-intel}" == "nvidia" ]]; then
    log_info "NVIDIA GPU detected. This repo still will not install CUDA automatically."
    log_info "Install the Ubuntu NVIDIA driver yourself if you want GPU acceleration."
  else
    log_info "Intel/other GPU: skipping CUDA, NVIDIA drivers, and GPU-only AI stacks."
  fi

  if apt_package_available ollama; then
    apt_install_missing ollama
  else
    log_info "ollama is not in this Ubuntu archive. Install later from https://ollama.com if you want it."
    log_info "This installer will not pipe a remote script into the shell."
  fi

  state_append_list "MODULES" "ai-packages"
}

_ai_detect_gpu() {
  UDF_GPU_VENDOR="unknown"
  local pci=""
  pci="$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true)"
  if printf '%s\n' "${pci}" | grep -qi nvidia; then
    UDF_GPU_VENDOR="nvidia"
  elif printf '%s\n' "${pci}" | grep -qi intel; then
    UDF_GPU_VENDOR="intel"
  elif printf '%s\n' "${pci}" | grep -qi amd; then
    UDF_GPU_VENDOR="amd"
  fi
  export UDF_GPU_VENDOR
  log_info "GPU vendor: ${UDF_GPU_VENDOR}"
  if [[ -n "${pci}" ]]; then
    log_info "${pci}"
  fi
}
