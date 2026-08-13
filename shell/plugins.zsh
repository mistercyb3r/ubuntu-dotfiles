# Lightweight zsh plugins. No Oh My Zsh. Highlighting must load last.

mkdir -p "${HOME}/.cache/zsh" 2>/dev/null || true

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS SHARE_HISTORY EXTENDED_HISTORY
setopt INTERACTIVE_COMMENTS AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt COMPLETE_IN_WORD
unsetopt BEEP

# Completions (rebuild dump at most once a day)
autoload -Uz compinit
_udf_dump="${HOME}/.cache/zsh/zcompdump"
if [[ ! -f "${_udf_dump}" ]] || [[ -n "$(find "${_udf_dump}" -mtime +1 2>/dev/null)" ]]; then
  compinit -d "${_udf_dump}"
else
  compinit -C -d "${_udf_dump}"
fi
unset _udf_dump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'

# Autosuggestions (right-arrow accepts). Muted grey matches the theme.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${UDF_MUTED:-#4C566A}"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40

_udf_plugin_dirs=(
  /usr/share/zsh-autosuggestions
  /usr/share/zsh/plugins/zsh-autosuggestions
  "${HOME}/.local/share/ubuntu-dotfiles/zsh/zsh-autosuggestions"
)
for _udf_d in "${_udf_plugin_dirs[@]}"; do
  if [[ -f "${_udf_d}/zsh-autosuggestions.zsh" ]]; then
    source "${_udf_d}/zsh-autosuggestions.zsh"
    break
  fi
done
unset _udf_d _udf_plugin_dirs

# fzf keybindings: CTRL-R history, CTRL-T files
for _udf_f in \
  /usr/share/doc/fzf/examples/key-bindings.zsh \
  /usr/share/fzf/key-bindings.zsh \
  /usr/share/fzf/shell/key-bindings.zsh
do
  if [[ -f "${_udf_f}" ]]; then
    source "${_udf_f}"
    break
  fi
done
for _udf_f in \
  /usr/share/doc/fzf/examples/completion.zsh \
  /usr/share/fzf/completion.zsh \
  /usr/share/fzf/shell/completion.zsh
do
  if [[ -f "${_udf_f}" ]]; then
    source "${_udf_f}"
    break
  fi
done
unset _udf_f

# Syntax highlighting last. Green valid / red invalid.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]="fg=${UDF_GREEN:-#A3BE8C}"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${UDF_GREEN:-#A3BE8C}"
ZSH_HIGHLIGHT_STYLES[alias]="fg=${UDF_GREEN:-#A3BE8C}"
ZSH_HIGHLIGHT_STYLES[function]="fg=${UDF_GREEN:-#A3BE8C}"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${UDF_RED:-#BF616A},bold"
ZSH_HIGHLIGHT_STYLES[path]="fg=${UDF_CYAN:-#88C0D0},underline"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${UDF_PURPLE:-#B48EAD}"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${UDF_PURPLE:-#B48EAD}"
ZSH_HIGHLIGHT_STYLES[comment]="fg=${UDF_MUTED:-#4C566A}"

_udf_hl_dirs=(
  /usr/share/zsh-syntax-highlighting
  /usr/share/zsh/plugins/zsh-syntax-highlighting
  "${HOME}/.local/share/ubuntu-dotfiles/zsh/zsh-syntax-highlighting"
)
for _udf_d in "${_udf_hl_dirs[@]}"; do
  if [[ -f "${_udf_d}/zsh-syntax-highlighting.zsh" ]]; then
    source "${_udf_d}/zsh-syntax-highlighting.zsh"
    break
  fi
done
unset _udf_d _udf_hl_dirs
