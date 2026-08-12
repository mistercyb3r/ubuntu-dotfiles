# Safe, explicit aliases. No wrapping of rm/mv/cp — those must keep POSIX behaviour
# so scripts and muscle memory never diverge.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias projects='cd "${HOME}/Projects"'

# Listing: eza when present, otherwise GNU ls
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --git'
  alias ll='eza -l --group-directories-first --git --header'
  alias la='eza -la --group-directories-first --git --header'
  alias lt='eza -T --level=2 --group-directories-first'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh --color=auto --group-directories-first'
  alias la='ls -lha --color=auto --group-directories-first'
fi

# Safer visual defaults (not destructive)
alias grep='grep --color=auto'
alias diff='diff --color=auto'

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi

if command -v fd >/dev/null 2>&1; then
  :
elif command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

alias rg='rg --hidden --glob "!.git"'

# Git (short, non-destructive)
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate -20'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gpl='git pull'

# Docker (only if installed)
if command -v docker >/dev/null 2>&1; then
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias dimg='docker images'
  alias dcu='docker compose up'
  alias dcd='docker compose down'
  alias dcl='docker compose logs -f'
fi

# System
alias update='system-update'
alias sysinfo='system-info'
alias ports='ss -tulpn'
alias myip='hostname -I'

# Path helpers
alias path='printf "%s\n" "${PATH}" | tr ":" "\n"'
