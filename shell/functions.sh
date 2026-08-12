# Interactive helper functions. Keep them explicit; none hide destructive behaviour.

# Make a directory and enter it.
mkcd() {
  mkdir -p -- "$1" && cd -- "$1" || return
}

# Fuzzy-cd from the current directory (requires fzf).
fcd() {
  local dir
  dir="$(fd --type d --hidden --exclude .git . 2>/dev/null | fzf)" || return
  cd -- "${dir}" || return
}

# Fuzzy-open a file in $EDITOR.
fe() {
  local file
  file="$(fd --type f --hidden --exclude .git . 2>/dev/null | fzf)" || return
  "${EDITOR:-nano}" -- "${file}"
}

# Git: pick a branch with fzf and switch.
gbs() {
  local branch
  branch="$(git branch --all --format='%(refname:short)' 2>/dev/null | fzf)" || return
  git switch "${branch#origin/}"
}

# Show the public key that should be added to GitHub.
sshpubkey() {
  local pub="${HOME}/.ssh/id_ed25519.pub"
  if [[ ! -f "${pub}" ]]; then
    pub="${HOME}/.ssh/id_rsa.pub"
  fi
  if [[ ! -f "${pub}" ]]; then
    printf 'No public key found. Run ssh-keygen -t ed25519\n' >&2
    return 1
  fi
  cat "${pub}"
  if command -v xclip >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" ]]; then
    xclip -selection clipboard < "${pub}"
    printf '\n(copied to clipboard)\n'
  elif command -v wl-copy >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    wl-copy < "${pub}"
    printf '\n(copied to clipboard)\n'
  fi
}

# Extract common archives into a new directory named after the file.
extract() {
  local archive="$1"
  if [[ -z "${archive}" || ! -f "${archive}" ]]; then
    printf 'usage: extract <archive>\n' >&2
    return 1
  fi
  case "${archive}" in
    *.tar.bz2|*.tbz2) tar xjf "${archive}" ;;
    *.tar.gz|*.tgz)   tar xzf "${archive}" ;;
    *.tar.xz)         tar xJf "${archive}" ;;
    *.tar)            tar xf "${archive}" ;;
    *.zip)            unzip "${archive}" ;;
    *.gz)             gunzip -k "${archive}" ;;
    *.bz2)            bunzip2 -k "${archive}" ;;
    *) printf 'unknown archive type: %s\n' "${archive}" >&2; return 1 ;;
  esac
}

# Quick HTTP server in the current directory (Python).
serve() {
  local port="${1:-8000}"
  python3 -m http.server "${port}"
}

# Print a reminder instead of wrapping rm.
# (Intentionally not an alias for rm.)
trash-hint() {
  printf 'This environment does not alias rm. Use rm -i interactively, or gio trash FILE.\n'
}

# Load nvm immediately (if you need it in a script-like interactive session).
loadnvm() {
  export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"
  # shellcheck disable=SC1091
  [[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"
}

# Measure shell startup (for sanity checks after editing zshrc).
zsh-startup() {
  local i
  for i in 1 2 3; do
    time zsh -lic 'exit'
  done
}
