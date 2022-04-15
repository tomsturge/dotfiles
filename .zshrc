# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

source $HOME/.aliases

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export TERM="xterm-256color"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(
  git 
  github 
  npm 
  tmux 
  zsh-syntax-highlighting 
  zsh-autosuggestions
)

# User configuration

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs aws nvm newline)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time nordvpn battery newline)

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export EDITOR=vi
export VISUAL=vi
export PATH=$HOME/.linuxbrew/bin:$PATH
export PATH=$PATH:/snap/bin

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
emulate sh -c 'source /etc/profile'
export PATH="$HOME/.tgenv/bin:$PATH"
source /Users/tomsturge/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/usr/local/opt/mongodb-community@4.2/bin:$PATH"

# Fig post block. Keep at the bottom of this file.
. "$HOME/.fig/shell/zshrc.post.zsh"
