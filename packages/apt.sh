#!/usr/bin/env bash
# Core apt packages for a developer laptop.
# Prefer Ubuntu archive packages. Skip names that are not in this release.
# neofetch is never installed. Fastfetch is the greeting (packages/terminal.sh).

# Packages that should exist on Ubuntu 22.04 and 24.04 LTS.
APT_CORE_PACKAGES=(
  build-essential
  ca-certificates
  curl
  wget
  git
  unzip
  zip
  tar
  gzip
  gnupg
  lsb-release
  software-properties-common
  apt-transport-https
  openssh-client
  jq
  tree
  htop
  tmux
  fzf
  ripgrep
  fd-find
  bat
  zsh
  python3
  python3-venv
  python3-pip
  python3-dev
  pipx
  fonts-jetbrains-mono
  xclip
  git-lfs
  shellcheck
  man-db
  less
  file
  pciutils
  usbutils
  net-tools
  iproute2
  dnsutils
  ca-certificates
)

# Present on recent Ubuntu; skipped automatically if the archive does not have them.
APT_CORE_OPTIONAL=(
  btop
  eza
  wl-clipboard
  plocate
  fonts-firacode
  ncdu
  mtr-tiny
  traceroute
  whois
  smartmontools
  lazygit
  shfmt
)

install_apt_packages() {
  log_info "Installing core command-line packages from Ubuntu repositories"
  apt_update_once
  apt_install_missing "${APT_CORE_PACKAGES[@]}"
  apt_install_missing "${APT_CORE_OPTIONAL[@]}"

  _apt_link_ubuntu_renames
  state_append_list "MODULES" "apt"
}

# Ubuntu ships some tools under Debian-safe names. Add user-facing aliases
# as wrappers in ~/.local/bin without touching system files.
_apt_link_ubuntu_renames() {
  mkdir -p "${XDG_BIN_HOME}"

  if command_exists batcat && ! command_exists bat; then
    if is_dry_run; then
      log_dry "ln -sfn $(command -v batcat) ${XDG_BIN_HOME}/bat"
    else
      ln -sfn "$(command -v batcat)" "${XDG_BIN_HOME}/bat"
      log_success "Linked bat -> batcat"
    fi
  fi

  if command_exists fdfind && ! command_exists fd; then
    if is_dry_run; then
      log_dry "ln -sfn $(command -v fdfind) ${XDG_BIN_HOME}/fd"
    else
      ln -sfn "$(command -v fdfind)" "${XDG_BIN_HOME}/fd"
      log_success "Linked fd -> fdfind"
    fi
  fi
}
