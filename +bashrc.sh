#!/bin/bash

# aggiungere
HISTSIZE=25000
HISTFILESIZE=25000
#alias
alias ll='ls -la --color=auto'
alias ls='exa'
alias gc='git commit -m'
alias gf='git fetch'
alias gck='git checkout'
alias gpl='git pull'
alias gph='git push'
alias vim='nvim'
alias ip='ip -c a'
alias aur-install='makepkg -si'

#programmi
# Dracula theme for Bash
export PS1="\[\033[38;5;204m\]\u\[$(tput sgr0)\]@\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;108m\]\h\[$(tput sgr0)\]:\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;216m\]\w\[$(tput sgr0)\]\[\033[38;5;37m\]\$ \[$(tput sgr0)\]"
neofetch

#path variabili


