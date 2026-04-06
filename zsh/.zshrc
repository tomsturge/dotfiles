# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

# Powerlevel10k
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# PATH
export PATH="$HOME/.local/bin:$PATH"

# fnm
if [ -d "$HOME/.local/share/fnm" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
fi
if command -v fnm &> /dev/null; then
  eval "$(fnm env)"
fi

# bat (aliased as cat)
alias cat='bat --paging=never'

# eza (aliased as ls)
alias ls='eza --icons --group-directories-first'
alias ll='eza --icons --group-directories-first -la'
alias la='eza --icons --group-directories-first -a'

# fzf
if command -v fzf &> /dev/null; then
  source <(fzf --zsh 2>/dev/null) || true
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Default working directory
[[ -d ~/repos ]] || mkdir -p ~/repos
cd ~/repos

# Tmux autostart (only if start_tmux.sh is present — deployed via --dev)
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -x "$HOME/.local/bin/start_tmux.sh" ]; then
  "$HOME/.local/bin/start_tmux.sh"
fi
