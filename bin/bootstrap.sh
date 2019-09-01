#!/bin/bash

# Initialize a few things
init () {
	echo "Creating applications folder"
	mkdir -p "$HOME/apps"
	echo "Creating projects folder"
	mkdir -p "$HOME/projects"
}

# TODO : Delete symlinks to deleted files
# Is this where rsync shines?
# TODO - add support for -f and --force
link () {
	echo "Symlink files? y/n"
	read resp
	# TODO - regex here?
	if [ "$resp" = 'y' -o "$resp" = 'Y' ] ; then
		for file in $( ls -A | grep -vE '\.exclude*|\.git$|\.gitignore|.*.md' ) ; do
			ln -sv "$PWD/$file" "$HOME"
		done
		# TODO: source files here?
		echo "Symlinking complete"
	else
		echo "Symlinking cancelled"
		return 1
	fi
}

utilities () {
	if [ $( echo "$OSTYPE" | grep 'linux-gnu' ) ] ; then
		echo "Install utilities? y/n"
		read resp
		# TODO - regex here?
		if [ "$resp" = 'y' -o "$resp" = 'Y' ] ; then
			echo "Installing. This may take a while..."
			sh ./utilites.sh
		else
			echo "Utilities installation cancelled"
		fi
	fi
}


# ===
# SETUP
# ===
# 
# Add user to sudoers
# > echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
#
# ---
#
# Install git
# > sudo apt-get install git

# ===
# INSTALL FONT
# ===
#
# curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip
# sudo mkdir /usr/share/fonts/opentype/FuraCode
# unzip -p "FiraCode.zip Fura\ Code\ Regular\ Nerd\ Font\ Complete.otf" >/usr/share/fonts/opentype/FuraCode/FuraCode.otf
# fc-cache -f -v

# ===
# UTILITIES
# ===
#
# Bat - Cat alternative
# > sudo dpkg -i bat_0.9.0_amd64.deb
# alias cat='bat'
#
# ---
#
# JQ - JSON parser
# > sudo apt-get install jq
#
# ---
#
# Diff-so-fancy - Better git diff
# > npm i -g diff-so-fancy
# > git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
# > git config --global color.ui true
# > git config --global color.diff-highlight.oldNormal "red bold"
# > git config --global color.diff-highlight.oldHighlight "red bold 52"
# > git config --global color.diff-highlight.newNormal "green bold"
# > git config --global color.diff-highlight.newHighlight "green bold 22"
# > git config --global color.diff.meta "yellow"
# > git config --global color.diff.frag "magenta bold"
# > git config --global color.diff.commit "yellow bold"
# > git config --global color.diff.old "red bold"
# > git config --global color.diff.new  "green bold"
# > git config --global color.diff.whitespace "red reverse"
#
# ---
#
# Ag - Grep alternative
# > sudo apt-get install silversearcher-ag
#
# ---
#
# tldr - man page alternative
# > npm install -g tldr
# alias help='tldr'
#
# ---
#
# ncdu - cli daisydisk
# > sudo apt-get install ncdu

init
link
utilities