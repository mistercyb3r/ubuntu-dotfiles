#!/usr/bin/env bash
# Ubuntu Latitude 5400 developer workstation installer.
# Safe to re-run. Never run this on Windows.
set -euo pipefail

INSTALL_TOTAL_STEPS=10

usage() {
  cat <<'EOF'
Ubuntu Latitude 5400 developer workstation installer

Usage: ./install.sh [options]

Options:
  --full          All modules (default): packages, shell, git, terminal,
                  GNOME, Python, Node, Docker, projects, performance
  --minimal       Packages, shell, git, terminal, projects. Skips GNOME,
                  Docker, Node, optional extras
  --no-gnome      Skip GNOME desktop settings
  --no-docker     Skip Docker
  --no-node       Skip nvm / Node.js
  --no-python     Skip pipx / uv (Python 3 from apt is still installed)
  --no-look       Skip GNOME theme / wallpaper / Papirus (terminal stack still installs)
  --pentest       Install optional lab / pentest tools (nmap, wireshark, ...)
  --hyprland      Install an optional Hyprland session (GNOME stays default)
  --ai            Prepare local AI dirs; detect GPU; no CUDA on Intel
  --gaming        Prepare game/mod dirs; does not install Steam/Godot/Blender
  --languages     Optional Rust / Go / JDK from apt if missing
  --virt          Optional QEMU/KVM + virt-manager
  --dry-run       Print actions without changing the system
  --yes, -y       Assume "yes" for confirmation prompts
  --help, -h      Show this help

This script refuses to run on Windows, MSYS, Cygwin, or as root.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/common.sh"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/lib/os.sh"

SKIP_GNOME=0
SKIP_DOCKER=0
SKIP_NODE=0
SKIP_PYTHON=0
SKIP_LOOK=0
ENABLE_PENTEST=0
ENABLE_HYPRLAND=0
ENABLE_AI=0
ENABLE_GAMING=0
ENABLE_LANGUAGES=0
ENABLE_VIRT=0
INSTALL_PROFILE="full"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --full) INSTALL_PROFILE="full"; shift ;;
    --minimal)
      INSTALL_PROFILE="minimal"
      SKIP_GNOME=1
      SKIP_DOCKER=1
      SKIP_NODE=1
      SKIP_LOOK=1
      shift
      ;;
    --no-gnome) SKIP_GNOME=1; shift ;;
    --no-docker) SKIP_DOCKER=1; shift ;;
    --no-node) SKIP_NODE=1; shift ;;
    --no-python) SKIP_PYTHON=1; shift ;;
    --no-look) SKIP_LOOK=1; shift ;;
    --pentest) ENABLE_PENTEST=1; shift ;;
    --hyprland) ENABLE_HYPRLAND=1; shift ;;
    --ai) ENABLE_AI=1; shift ;;
    --gaming) ENABLE_GAMING=1; shift ;;
    --languages) ENABLE_LANGUAGES=1; shift ;;
    --virt) ENABLE_VIRT=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

export DRY_RUN ASSUME_YES INSTALL_PROFILE SKIP_GNOME SKIP_DOCKER SKIP_NODE SKIP_PYTHON SKIP_LOOK
export ENABLE_PENTEST ENABLE_HYPRLAND ENABLE_AI ENABLE_GAMING ENABLE_LANGUAGES ENABLE_VIRT

print_banner() {
  printf '%s\n' "${C_BOLD}${C_CYAN}"
  cat <<'EOF'
  Ubuntu Latitude 5400
  Developer Workstation
EOF
  printf '%s' "${C_RESET}"
  printf '  version %s  profile=%s' "${DOTFILES_VERSION}" "${INSTALL_PROFILE}"
  if is_dry_run; then
    printf '  %sDRY-RUN%s' "${C_YELLOW}" "${C_RESET}"
  fi
  printf '\n\n'
}

source_modules() {
  local f
  for f in \
    "${REPO_ROOT}/bootstrap/prerequisites.sh" \
    "${REPO_ROOT}/packages/apt.sh" \
    "${REPO_ROOT}/packages/terminal.sh" \
    "${REPO_ROOT}/packages/development.sh" \
    "${REPO_ROOT}/packages/optional.sh" \
    "${REPO_ROOT}/packages/look.sh" \
    "${REPO_ROOT}/packages/pentest.sh" \
    "${REPO_ROOT}/packages/hyprland.sh" \
    "${REPO_ROOT}/packages/languages.sh" \
    "${REPO_ROOT}/packages/ai.sh" \
    "${REPO_ROOT}/packages/gaming.sh" \
    "${REPO_ROOT}/packages/virt.sh" \
    "${REPO_ROOT}/modules/shell.sh" \
    "${REPO_ROOT}/modules/git.sh" \
    "${REPO_ROOT}/modules/terminal.sh" \
    "${REPO_ROOT}/modules/ssh.sh" \
    "${REPO_ROOT}/modules/gnome.sh" \
    "${REPO_ROOT}/modules/fonts.sh" \
    "${REPO_ROOT}/modules/look.sh" \
    "${REPO_ROOT}/modules/performance.sh" \
    "${REPO_ROOT}/modules/projects.sh" \
    "${REPO_ROOT}/modules/hyprland.sh" \
    "${REPO_ROOT}/modules/ai.sh" \
    "${REPO_ROOT}/modules/gaming.sh" \
    "${REPO_ROOT}/modules/health.sh"
  do
    # shellcheck disable=SC1090
    . "${f}"
  done
}

main() {
  print_banner
  assert_not_windows
  assert_unix_line_endings

  log_step 1 "${INSTALL_TOTAL_STEPS}" "Checking system"
  os_assert_not_root
  os_assert_compatible
  os_print_summary
  if ! is_dry_run; then
    os_assert_sudo
  else
    log_dry "sudo will be required on a real run"
  fi
  source_modules
  ensure_state_dirs
  save_repo_path
  state_set "INSTALL_PROFILE" "${INSTALL_PROFILE}"
  state_set "INSTALLED_AT" "$(date -Iseconds 2>/dev/null || date)"

  log_step 2 "${INSTALL_TOTAL_STEPS}" "Installing packages"
  bootstrap_prerequisites
  install_apt_packages
  install_terminal_packages
  if [[ "${INSTALL_PROFILE}" == "full" ]]; then
    install_optional_packages
  else
    log_skip "Optional packages (use --full)"
    if [[ "${SKIP_DOCKER}" != "1" ]]; then
      install_docker
    fi
  fi

  log_step 3 "${INSTALL_TOTAL_STEPS}" "Configuring shell"
  configure_shell

  log_step 4 "${INSTALL_TOTAL_STEPS}" "Configuring Git"
  configure_git

  log_step 5 "${INSTALL_TOTAL_STEPS}" "Configuring terminal"
  configure_terminal
  configure_ssh

  log_step 6 "${INSTALL_TOTAL_STEPS}" "Configuring GNOME"
  configure_gnome
  configure_fonts
  install_look_packages
  configure_look
  install_pentest_packages
  install_hyprland_packages
  configure_hyprland

  log_step 7 "${INSTALL_TOTAL_STEPS}" "Configuring development tools"
  install_development_packages
  install_optional_languages
  install_ai_packages
  configure_ai
  install_gaming_packages
  configure_gaming
  install_virt_packages
  configure_performance

  log_step 8 "${INSTALL_TOTAL_STEPS}" "Configuring project directories"
  configure_projects

  log_step 9 "${INSTALL_TOTAL_STEPS}" "Running health checks"
  run_health_checks

  log_step 10 "${INSTALL_TOTAL_STEPS}" "Complete"
  print_next_steps
}

print_next_steps() {
  cat <<EOF

${C_BOLD}Finished.${C_RESET} Backups (if any) are under:
  ${DOTFILES_BACKUP_ROOT}

${C_BOLD}Manual steps (not automated on purpose):${C_RESET}
  1. Open a new terminal (or log out/in) so zsh, PATH and groups apply.
  2. Set Git identity:        setup-git-identity
  3. Add the SSH public key to GitHub:  sshpubkey
       then follow docs/github-ssh.md
  4. Log in to Tailscale:     sudo tailscale up
       then follow docs/tailscale.md
  5. Copy ~/.ssh/config.d/homelab.conf.example to a real *.conf
     and replace <TAILSCALE_IP> / <USERNAME>
  6. If you were added to the docker group, log out and back in.
     This installer will not reboot the machine.

${C_BOLD}The desktop does not change from git pull alone.${C_RESET}
  Close every terminal, then log out and back in.
  If the wallpaper/theme still looks old, run this on the desktop:
    bash scripts/apply-look.sh

${C_BOLD}Prove the terminal actually changed:${C_RESET}
  preview-terminal
  dotfiles-health
  zsh-bench

${C_BOLD}Useful commands:${C_RESET}
  system-info          hardware and toolchain snapshot
  system-update        apt / snap / pipx updates
  new-project python x create a project under ~/Projects
  server list          SSH hosts from your config
  ssh-home             SSH Host homeserver (from your config)
  check-secrets        scan a directory before committing
  fetch                Fastfetch greeting
  tm / ta <session>    tmux (does not auto-start)

Documentation: ${REPO_ROOT}/docs/terminal.md
EOF
}

main "$@"
