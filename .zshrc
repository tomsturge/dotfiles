# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Path to your oh-my-zsh installation.
export ZSH=/Users/tomsturge/.oh-my-zsh

ZSH_THEME="cobalt2"

plugins=(git)

# User configuration

export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin://anaconda/bin:/Users/tomsturge/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh
export PATH="$PATH:./node_modules/.bin"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Add Spotify controls to terminal
export PATH="$HOME/.path_includes/:$PATH"


function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}
