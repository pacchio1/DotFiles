#!/bin/bash

########## Confisurazione BASH ##########

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

HISTSIZE=25000
HISTFILESIZE=25000

shopt -s histappend
shopt -s checkwinsize
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

########  path variabili ##

#doom emacs
export PATH=$PATH:~/.config/emacs/bin
#rust
if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
fi
export GTK_THEME=Dracula
export ICONS_THEME=Papirus

if [ -f "$HOME/.pyenv" ]; then

	export PYENV_ROOT="$HOME/.pyenv"
	export PYENV_ROOT="$HOME/.pyenv"
	[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
fi
########## tmux ##########

# Verifica se la variabile di controllo è impostata e se non siamo già dentro una sessione tmux
if [ -z "$TMUX" ]; then
	# Esegui il comando solo se la variabile non è impostata e non siamo già dentro una sessione tmux
	#!/bin/bash

	# Controlla se tmux ls ha un risultato
	if tmux ls 2>/dev/null; then
		# Se c'è una sessione esistente, collegati ad essa
		tmux a -t 0
	else
		# Se non ci sono sessioni, avviane una nuova
		tmux
	fi

	# Imposta la variabile di controllo
fi

########## Alias ##########

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

########## programmi ##########

# Dracula theme for Bash
export PS1="\[\033[38;5;204m\]\u\[$(tput sgr0)\]@\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;108m\]\h\[$(tput sgr0)\]:\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;216m\]\w\[$(tput sgr0)\]\[\033[38;5;37m\]\$ \[$(tput sgr0)\]"

#x=$((RANDOM % 8))
#y=$((RANDOM % 7+1))
#z=$((RANDOM % 8))

#echo "Random numbers: $x, $y, $z"
#neofetch --ascii_colors "$x" "$y" "$z" "$z" "$y" "$x"
##### ----------- basta ------------------------
#neofetch

#store credential git
git config --global credential.helper store

#angular
if command -v ng &>/dev/null; then
	source <(ng completion script)
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
