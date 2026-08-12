#!/usr/bin/env bash
# Print a concise snapshot of this developer workstation.
set -euo pipefail

_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${_here}/../lib/common.sh"
# shellcheck disable=SC1091
. "${_here}/../lib/os.sh"
os_load_release

section() { printf '\n%s%s%s\n' "${C_BOLD}" "$1" "${C_RESET}"; }
kv() { printf '  %-16s %s\n' "$1" "$2"; }

section "Operating system"
kv "OS" "${OS_PRETTY:-unknown}"
kv "Kernel" "$(uname -r)"
kv "Arch" "$(uname -m)"
kv "Host" "$(hostname)"
kv "User" "$(id -un)"
kv "Home" "${HOME}"
kv "Uptime" "$(uptime -p 2>/dev/null || uptime)"

section "Hardware"
if [[ -f /proc/cpuinfo ]]; then
  kv "CPU" "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')"
  kv "Cores" "$(nproc)"
fi
if [[ -f /proc/meminfo ]]; then
  kv "Memory" "$(awk '/MemTotal/ {printf "%.1f GiB", $2/1024/1024}' /proc/meminfo)"
  kv "MemAvail" "$(awk '/MemAvailable/ {printf "%.1f GiB", $2/1024/1024}' /proc/meminfo)"
fi
if command_exists lsblk; then
  echo "  Disks:"
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,ROTA -d 2>/dev/null | sed 's/^/    /' || true
fi
df -hT / 2>/dev/null | sed 's/^/  /' || true

section "Battery"
if command_exists upower; then
  bat="$(upower -e 2>/dev/null | grep -i battery | head -n1 || true)"
  if [[ -n "${bat}" ]]; then
    upower -i "${bat}" 2>/dev/null | grep -E 'state|percentage|time to|energy-full' | sed 's/^/ /'
  else
    kv "Battery" "not detected"
  fi
elif [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
  kv "Charge" "$(cat /sys/class/power_supply/BAT0/capacity)%"
  kv "Status" "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo unknown)"
else
  kv "Battery" "not detected"
fi

section "Network"
if command_exists hostname; then
  kv "IPv4" "$(hostname -I 2>/dev/null || echo unknown)"
fi
if command_exists ip; then
  echo "  Interfaces:"
  ip -br addr 2>/dev/null | sed 's/^/    /' || true
fi

section "Tailscale"
if command_exists tailscale; then
  tailscale status 2>/dev/null | head -n 20 | sed 's/^/  /' || kv "Status" "installed, not logged in or daemon down"
else
  kv "Tailscale" "not installed"
fi

section "Docker"
if command_exists docker; then
  kv "Version" "$(docker --version 2>/dev/null)"
  if docker info >/dev/null 2>&1; then
    kv "Daemon" "reachable"
  else
    kv "Daemon" "not reachable (permission or service)"
  fi
else
  kv "Docker" "not installed"
fi

section "Developer tools"
kv "Git" "$(git --version 2>/dev/null || echo missing)"
kv "Git user" "$(git config --global --get user.name 2>/dev/null || echo '(not set)')"
kv "Git email" "$(git config --global --get user.email 2>/dev/null || echo '(not set)')"
kv "gh" "$(gh --version 2>/dev/null | head -n1 || echo missing)"
kv "Python" "$(python3 --version 2>/dev/null || echo missing)"
kv "pipx" "$(pipx --version 2>/dev/null || echo missing)"
kv "uv" "$(uv --version 2>/dev/null || echo missing)"
if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  . "${HOME}/.nvm/nvm.sh"
fi
kv "Node" "$(node --version 2>/dev/null || echo missing)"
kv "npm" "$(npm --version 2>/dev/null || echo missing)"
kv "Zsh" "$(zsh --version 2>/dev/null || echo missing)"
kv "Starship" "$(starship --version 2>/dev/null | head -n1 || echo missing)"
kv "tmux" "$(tmux -V 2>/dev/null || echo missing)"
kv "rg" "$(rg --version 2>/dev/null | head -n1 || echo missing)"
kv "fzf" "$(fzf --version 2>/dev/null || echo missing)"
