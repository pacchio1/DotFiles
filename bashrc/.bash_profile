# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

#=====Path
#==Lang_bins

#=====Export

# export GTK_THEME=Dracula
#export ICONS_THEME=Papirus
#export GTK_THEME=Adwaita-dark

#export GTK_THEME=Gruvbox-Dark-Medium-B-MB
#export GTK_THEME=Orchis-Dark
#export GTK_THEME=Gruvbox-Dark
#export GTK_THEME=WhiteSur-Dark

#export PATH=$PATH:/usr/share/sdk-android-tool/platform-tools

#doom emacs
export PATH=$PATH:~/.config/emacs/bin

export PATH="$PATH:/home/mark/.local/bin"

export PATH="$HOME/.tmuxifier/bin:$PATH"
#=====Eval
eval "$(tmuxifier init -)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#=====AutoCreated
if [ -f "/home/mark/.config/fabric/fabric-bootstrap.inc" ]; then . "/home/mark/.config/fabric/fabric-bootstrap.inc"; fi
