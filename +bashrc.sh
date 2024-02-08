#!/bin/bash

# aggiungere
HISTSIZE=25000
HISTFILESIZE=25000


#programmi
# Dracula theme for Bash
export PS1="\[\033[38;5;204m\]\u\[$(tput sgr0)\]@\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;108m\]\h\[$(tput sgr0)\]:\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;216m\]\w\[$(tput sgr0)\]\[\033[38;5;37m\]\$ \[$(tput sgr0)\]"

neofetch
#tmux
# Verifica se la variabile di controllo è impostata e se non siamo già dentro una sessione tmux
if [ -z "$TMUX_STARTED" ] && [ -z "$TMUX" ]; then
            # Esegui il comando solo se la variabile non è impostata e non siamo già dentro una sessione tmux
                tmux

                    # Imposta la variabile di controllo
                        export TMUX_STARTED=1
fi
#path variabili

#Alias 

#commands
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
alias i3config='nvim ~/.config/i3/config'
alias i3status-config='nvim ~/.config/i3status/config'

#Angular
alias ngs='ng serve'
alias nggc='ng generate component'
alias nggm='ng generate module'
alias nggs='ng generate service'
#node
alias npmi='npm install'
alias npms='npm start'
