# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

#=====Path
#==Lang_bins
#SDK(java)
if command -v sdk2>/dev/null; then
	export SDKMAN_DIR="$HOME/.sdkman"
fi
#rust
if command -v rust 2>/dev/null; then
	. "$HOME/.cargo/env"
fi
#angular
if command -v ng 2>/dev/null; then
	source <(ng completion script)
fi
if [ -f "$HOME/.pyenv" ]; then
	export PYENV_ROOT="$HOME/.pyenv"
	[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
fi
#=====Export

# export GTK_THEME=Dracula
export ICONS_THEME=Papirus
export GTK_THEME=Gruvbox-Dark-Medium-B-MB

#export PATH=$PATH:/usr/share/sdk-android-tool/platform-tools

#doom emacs
export PATH=$PATH:~/.config/emacs/bin

export portatile=192.168.1.22
export PATH="$PATH:/home/mark/.local/bin"


#=====Eval
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# eval "$(pyenv init -)"
