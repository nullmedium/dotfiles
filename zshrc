#!/bin/zsh
# Zsh configuration file

# History configuration for persistent history across tmux sessions
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt SHARE_HISTORY          # Share history between all sessions
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS      # Don't display duplicates when searching history
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history items
setopt INC_APPEND_HISTORY     # Write to history file immediately, not when shell exits
setopt HIST_VERIFY            # Don't execute immediately upon history expansion

# Source common profile
[ -f "$HOME/.shell-common/profile.common" ] && source "$HOME/.shell-common/profile.common"

# Zsh-specific configurations
# Docker CLI completions (macOS specific path)
if [ "$OS" = "macos" ] && [ -d "/Users/jens/.docker/completions" ]; then
    fpath=(/Users/jens/.docker/completions $fpath)
fi

# Enable completions
autoload -Uz compinit
compinit

# Source fzf files for Ubuntu/Debian systems
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Useful aliases with fzf
alias fzp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias fzd='cd $(fd --type d --hidden --follow --exclude .git | fzf --preview "tree -C {} | head -200")'
alias fzv='vim $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'

# Git + fzf aliases
alias fgb='git branch | fzf | xargs git checkout'
alias fgl='git log --oneline | fzf --preview "git show --color=always {1}" | awk "{print \$1}" | xargs git show'

# Tmux session switcher with fzf
fts() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --preview "tmux list-windows -t {} | column -t" --preview-window=down:20%) && tmux switch-client -t "$session"
}

# Enhanced Zsh Prompt Configuration (now handled by Oh My Zsh + Spaceship)
# Enable prompt substitution and colors
# setopt PROMPT_SUBST
# autoload -U colors && colors

# Git prompt function
# git_prompt_info() {
#   local ref
#   ref=$(git symbolic-ref HEAD 2> /dev/null) || \
#   ref=$(git rev-parse --short HEAD 2> /dev/null) || return
#
#   # Get git status
#   local git_status=""
#   local STATUS=$(git status --porcelain 2> /dev/null | tail -1)
#
#   if [[ -n $STATUS ]]; then
#     git_status=" %{$fg[yellow]%}✗%{$reset_color%}"
#   else
#     git_status=" %{$fg[green]%}✓%{$reset_color%}"
#   fi
#
#   echo " %{$fg[cyan]%}(${ref#refs/heads/}${git_status}%{$fg[cyan]%})%{$reset_color%}"
# }
#
# # Virtual environment indicator
# virtualenv_prompt_info() {
#   if [[ -n "$VIRTUAL_ENV" ]]; then
#     echo "%{$fg[magenta]%}($(basename $VIRTUAL_ENV))%{$reset_color%} "
#   fi
# }
#
# # Exit code indicator
# exit_code_prompt() {
#   echo "%(?.%{$fg[green]%}➜%{$reset_color%}.%{$fg[red]%}➜%{$reset_color%})"
# }
#
# # Directory with truncation
# directory_prompt() {
#   echo "%{$fg[blue]%}%3~%{$reset_color%}"
# }
#
# # Username and hostname for SSH sessions
# user_host_prompt() {
#   if [[ -n "$SSH_CONNECTION" ]]; then
#     echo "%{$fg[yellow]%}%n@%m%{$reset_color%} "
#   fi
# }
#
# # Time in 24-hour format
# time_prompt() {
#   echo "%{$fg[lightgray]%}%T%{$reset_color%}"
# }
#
# # Main prompt
# PROMPT='$(user_host_prompt)$(virtualenv_prompt_info)$(directory_prompt)$(git_prompt_info) $(exit_code_prompt) '
#
# # Right prompt with time
# RPROMPT='$(time_prompt)'
#
# # Enable command execution time display
# function preexec() {
#   timer=${timer:-$SECONDS}
# }
#
# function precmd() {
#   if [ $timer ]; then
#     timer_show=$(($SECONDS - $timer))
#     if [ $timer_show -ge 3 ]; then
#       export RPS1="%{$fg[gray]%}${timer_show}s%{$reset_color%} $(time_prompt)"
#     else
#       export RPS1="$(time_prompt)"
#     fi
#     unset timer
#   fi
# }

# Oh My Zsh compatibility settings (for OMZ plugins)
export ZSH="$HOME/.dotfiles/zsh/oh-my-zsh"
export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR/completions"

# Sheldon plugin manager
export SHELDON_CONFIG_FILE="$HOME/.dotfiles/sheldon/plugins.toml"

# Cache Sheldon plugins for faster startup
eval "$(sheldon source)"

# Plugin customizations
# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Key bindings for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

source /home/jenlue/.config/broot/launcher/bash/br
