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


########## programmi ##########


# Dracula theme for Bash
export PS1="\[\033[38;5;204m\]\u\[$(tput sgr0)\]@\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;108m\]\h\[$(tput sgr0)\]:\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;216m\]\w\[$(tput sgr0)\]\[\033[38;5;37m\]\$ \[$(tput sgr0)\]"


x=$((RANDOM % 8))
y=$((RANDOM % 8))
z=$((RANDOM % 8))

#echo "Random numbers: $x, $y, $z"
neofetch --ascii_colors "$x" "$y" "$z" "$z" "$y" "$x"


#store credential git
git config --global credential.helper store


########## tmux ##########


#	# Verifica se la variabile di controllo è impostata e se non siamo già dentro una sessione tmux
#	if [ -z "$TMUX_STARTED" ] && [ -z "$TMUX" ]; then
#		# Esegui il comando solo se la variabile non è impostata e non siamo già dentro una sessione tmux
#		tmux
#
#		# Imposta la variabile di controllo
#		export TMUX_STARTED=1
#	fi
#	#path variabili



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
#vpn
alias vpn-excentio="cd ~ && sudo openvpn marcopacchiotti.ovpn"
#commands
alias ls='exa'
alias ll='ls -la --color=auto'
alias gc='git commit -m'
alias gf='git fetch'
alias gcheck='git checkout'
alias gpull='git pull'
alias gpush='git push'
alias vim='nvim'
alias ip='ip -c a'
alias aur-install='makepkg -si'
alias i3config='nvim ~/.config/i3/config'
alias i3status-config='nvim ~/.config/i3status/config'
alias cd2='cd ../..'
alias cd3='cd ../../..'
alias gitf='cd && cd git'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias podf='cd && cd docker'
alias dotf='gitf && cd DotFiles'
alias bashrc='cd && vim .bashrc'
alias i3c='vim ~/.config/i3/config'
alias i3sc='vim ~/.config/i3status/config'
alias swagger='http-server -p 8080 swagger-editor'
alias code='codium'
alias batteri3='vim +17 ~/.config/i3status/config'
#Angular
# Load Angular CLI autocompletion.
source <(ng completion script)
alias ngs='ng serve'
alias nggc='ng generate component'
alias nggm='ng generate module'
alias nggs='ng generate service'
#node
alias npmi='npm install'
alias npms='npm start'

#utility
alias n='cd && nano note'
