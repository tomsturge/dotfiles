# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

eval $(dinghy env)

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(git)

# User configuration

POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_SECOND_PROMPT_PREFIX="%F{white}$(print $'\u279C') %F{white}"
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time)

POWERLEVEL9K_HOME_FOLDER_ABBREVIATION=""
# POWERLEVEL9K_DIR_PATH_SEPARATOR="%F{black} $(print_icon 'LEFT_SUBSEGMENT_SEPARATOR') %F{black}"
POWERLEVEL9K_DIR_PATH_SEPARATOR="%F{black} $(print $'\uE0B1') %F{black}"

POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="008"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="black"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_ICON=""

POWERLEVEL9K_BATTERY_VERBOSE=false
POWERLEVEL9K_BATTERY_ICON=""
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=25
POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND="blue"
POWERLEVEL9K_BATTERY_LOW_COLOR_FOREGROUND="red"

POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"

function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

source $ZSH/oh-my-zsh.sh