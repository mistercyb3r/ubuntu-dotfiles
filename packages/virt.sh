#!/usr/bin/env bash
# Optional virtualization. Heavy; off unless ./install.sh --virt

install_virt_packages() {
  if [[ "${ENABLE_VIRT:-0}" != "1" ]]; then
    return 0
  fi

  log_info "Virtualization module (QEMU/KVM + virt-manager). Skip on battery-only days if you prefer."
  apt_install_missing qemu-system-x86 qemu-utils virt-manager libvirt-daemon-system libvirt-clients
  state_append_list "MODULES" "virt"
}
