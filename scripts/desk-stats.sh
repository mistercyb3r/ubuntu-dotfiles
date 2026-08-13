#!/usr/bin/env bash
# On-demand Nordic status card. No background daemon (Conky is not used on GNOME Wayland).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${ROOT}/theme/palette.env" ]]; then
  # shellcheck disable=SC1091
  . "${ROOT}/theme/palette.env"
fi

C_CYAN=$'\033[38;2;136;192;208m'
C_BLUE=$'\033[38;2;129;161;193m'
C_GREEN=$'\033[38;2;163;190;140m'
C_YELLOW=$'\033[38;2;235;203;139m'
C_RED=$'\033[38;2;191;97;106m'
C_PURPLE=$'\033[38;2;180;142;173m'
C_MUTED=$'\033[38;2;76;86;106m'
C_FG=$'\033[38;2;216;222;233m'
C_BOLD=$'\033[1m'
C_RESET=$'\033[0m'

bar() {
  local pct="${1:-0}"
  local width=24
  local filled=0
  pct="${pct%.*}"
  [[ "${pct}" =~ ^[0-9]+$ ]] || pct=0
  (( pct > 100 )) && pct=100
  filled=$(( pct * width / 100 ))
  local i color="${C_CYAN}"
  if (( pct >= 90 )); then color="${C_RED}"
  elif (( pct >= 70 )); then color="${C_YELLOW}"
  elif (( pct >= 40 )); then color="${C_GREEN}"
  fi
  printf '%s' "${color}"
  for (( i=0; i<filled; i++ )); do printf '█'; done
  printf '%s' "${C_MUTED}"
  for (( i=filled; i<width; i++ )); do printf '░'; done
  printf '%s %3s%%' "${C_RESET}" "${pct}"
}

cpu_pct() {
  awk -v n="$(nproc)" 'n<1{n=1} {p=$1*100/n; if(p>100)p=100; printf "%.0f", p}' /proc/loadavg 2>/dev/null || echo 0
}

mem_pct() {
  awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{if(t>0) printf "%.0f", (t-a)*100/t; else print 0}' /proc/meminfo 2>/dev/null || echo 0
}

mem_human() {
  awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.1f / %.1f GiB", (t-a)/1024/1024, t/1024/1024}' /proc/meminfo 2>/dev/null || echo unknown
}

disk_pct() {
  df -P / 2>/dev/null | awk 'NR==2{gsub(/%/,"",$5); print $5}'
}

disk_human() {
  df -hP / 2>/dev/null | awk 'NR==2{print $3" / "$2}'
}

battery() {
  if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
    printf '%s%% %s' "$(cat /sys/class/power_supply/BAT0/capacity)" \
      "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo)"
  else
    printf 'n/a'
  fi
}

temp_c() {
  local t
  t="$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1 || true)"
  if [[ -n "${t}" ]]; then
    awk -v n="${t}" 'BEGIN{printf "%.0f°C", n/1000}'
  else
    printf 'n/a'
  fi
}

loadavg() { awk '{print $1, $2, $3}' /proc/loadavg 2>/dev/null || echo n/a; }

printf '\n%s%s╭─ workstation%s\n' "${C_BOLD}" "${C_CYAN}" "${C_RESET}"
printf '%s│%s %s%s@%s%s  %s%s%s\n' \
  "${C_CYAN}" "${C_RESET}" "${C_PURPLE}" "$(id -un)" "$(hostname)" "${C_RESET}" \
  "${C_MUTED}" "$(uname -sr)" "${C_RESET}"
printf '%s│%s\n' "${C_CYAN}" "${C_RESET}"
printf '%s│%s  %scpu%s     %s  %s%s%s\n' "${C_CYAN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}" "$(bar "$(cpu_pct)")" "${C_MUTED}" "$(nproc) threads · load $(loadavg)" "${C_RESET}"
printf '%s│%s  %smem%s     %s  %s%s%s\n' "${C_CYAN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}" "$(bar "$(mem_pct)")" "${C_MUTED}" "$(mem_human)" "${C_RESET}"
printf '%s│%s  %sdisk%s    %s  %s%s%s\n' "${C_CYAN}" "${C_RESET}" "${C_BLUE}" "${C_RESET}" "$(bar "$(disk_pct)")" "${C_MUTED}" "$(disk_human) on /" "${C_RESET}"
printf '%s│%s  %sbattery%s %s%s  %stemp%s %s%s  %sup%s %s%s\n' \
  "${C_CYAN}" "${C_RESET}" \
  "${C_GREEN}" "${C_RESET}" "${C_FG}" "$(battery)" "${C_RESET}" \
  "${C_YELLOW}" "${C_RESET}" "${C_FG}" "$(temp_c)" "${C_RESET}" \
  "${C_PURPLE}" "${C_RESET}" "${C_FG}" "$(uptime -p 2>/dev/null || true)" "${C_RESET}"
printf '%s╰─%s %sbtop%s for live graphs · this card uses no background process\n\n' \
  "${C_CYAN}" "${C_RESET}" "${C_MUTED}" "${C_RESET}"
