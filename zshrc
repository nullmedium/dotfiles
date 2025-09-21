export GOPATH=$HOME/go
export PATH="$HOME/.cargo/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/jens/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
export PERPLEXITY_API_KEY="your-api-key"

# FZF configuration
# Enable fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# FZF environment variables
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --color=always --style=numbers --line-range=:500 {}"
  --preview-window=right:60%:wrap
  --bind "ctrl-/:toggle-preview"
  --bind "ctrl-y:execute-silent(echo {} | pbcopy)"
'

# Use fd for CTRL-T
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'
  --preview-window=right:60%:wrap
"

# Use fd for ALT-C
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Better history search with fzf
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=down:3:wrap
  --bind 'ctrl-y:execute-silent(echo {} | pbcopy)'
"

# FZF-tmux integration
export FZF_TMUX_OPTS='-p80%,60%'

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

# Enhanced Zsh Prompt Configuration
# Enable prompt substitution and colors
setopt PROMPT_SUBST
autoload -U colors && colors

# Git prompt function
git_prompt_info() {
  local ref
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return

  # Get git status
  local git_status=""
  local STATUS=$(git status --porcelain 2> /dev/null | tail -1)

  if [[ -n $STATUS ]]; then
    git_status=" %{$fg[yellow]%}✗%{$reset_color%}"
  else
    git_status=" %{$fg[green]%}✓%{$reset_color%}"
  fi

  echo " %{$fg[cyan]%}(${ref#refs/heads/}${git_status}%{$fg[cyan]%})%{$reset_color%}"
}

# Virtual environment indicator
virtualenv_prompt_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%{$fg[magenta]%}($(basename $VIRTUAL_ENV))%{$reset_color%} "
  fi
}

# Exit code indicator
exit_code_prompt() {
  echo "%(?.%{$fg[green]%}➜%{$reset_color%}.%{$fg[red]%}➜%{$reset_color%})"
}

# Directory with truncation
directory_prompt() {
  echo "%{$fg[blue]%}%3~%{$reset_color%}"
}

# Username and hostname for SSH sessions
user_host_prompt() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    echo "%{$fg[yellow]%}%n@%m%{$reset_color%} "
  fi
}

# Time in 24-hour format
time_prompt() {
  echo "%{$fg[gray]%}%T%{$reset_color%}"
}

# Main prompt
PROMPT='$(user_host_prompt)$(virtualenv_prompt_info)$(directory_prompt)$(git_prompt_info) $(exit_code_prompt) '

# Right prompt with time
RPROMPT='$(time_prompt)'

# Enable command execution time display
function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    if [ $timer_show -ge 3 ]; then
      export RPS1="%{$fg[gray]%}${timer_show}s%{$reset_color%} $(time_prompt)"
    else
      export RPS1="$(time_prompt)"
    fi
    unset timer
  fi
}
