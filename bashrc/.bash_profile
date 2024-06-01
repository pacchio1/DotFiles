# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

#Path

. "$HOME/.cargo/env"

#doom emacs
export PATH=$PATH:~/.config/emacs/bin
#rust
if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi
export GTK_THEME=Dracula
export ICONS_THEME=Papirus

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#export PATH=$PATH:/usr/share/sdk-android-tool/platform-tools

if [ -f "$HOME/.pyenv" ]; then

	export PYENV_ROOT="$HOME/.pyenv"
	export PYENV_ROOT="$HOME/.pyenv"
	[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
fi
#Export
export SDKMAN_DIR="$HOME/.sdkman"
export portatile=192.168.1.22
