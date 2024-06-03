# se si rompe qualcosa metterlo in bashrc

#vpn
alias vpn-excentio="cd ~ && sudo openvpn marcopacchiotti.ovpn"

#commands
alias ls='exa -a'
alias ll='ls -la --color=auto'
alias gc='git commit -m'
alias gadd='git add .'
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
alias gclone='git clone'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias podf='cd && cd docker'
alias dotf='gitf && cd DotFiles'
alias bashrc='cd && vim .bashrc'
alias malias='cd && vim .bash_aliases'
alias i3c='vim ~/.config/i3/config'
alias i3sc='vim ~/.config/i3status/config'
alias swagger='http-server -p 8080 swagger-editor'
alias code='codium'
alias batteri3='vim +17 ~/.config/i3status/config'
alias ngs='ng serve'
alias nggc='ng generate component'
alias nggm='ng generate module'
alias nggs='ng generate service'
alias dotnote='dotf && cd .other && vim .note.md '
alias l='clear'
alias v='vim'
alias emacs="doom run"
alias e='exit'
#alias stabledifusion-start='cd  ~/stablediff/  && ./webui.sh --listen --api'
#node
alias npmi='npm install'
alias npms='npm start'
#utility
alias n='cd && nano .note'
alias supergitpush='gadd && gc "super git push" && gpush'
alias murocarta='cd ~/wallpaper/WallPaper'
alias killtmux='tmux kill-ses -t'
alias sshPortatile='ssh mark@$portatile'
alias gnome-extensions-sync="cp -r /home/mark/.local/share/gnome-shell/extensions/* /home/mark/git/gnome-extension
                            && cd /home/mark/git/gnome-extension && supergitpush"
alias docker_onuse='export docker_inuso='
alias docker_onuse_console='docker exec -it $docker_inuso /bin/bash'
alias obsidian-sync='gitf && cd obsidian_pacchio && gpull && supergitpush'
alias pathandexport='nvim ~/.bash_aliases'

#tmp
alias beaglebone_c='sudo screen /dev/ttyACM0 115200'

