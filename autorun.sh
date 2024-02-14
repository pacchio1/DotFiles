###### Install Package First ######
links(){
    ln -sf ~/git/DotFiles/bashrc/daily.sh ~/.bashrc
    ln -sf ~/git/DotFiles/.config/i3/config ~/.config/i3/config
    ln -sf ~/git/DotFiles/.config/i3status/config ~/.config/i3status/config
    ln -sf ~/git/DotFiles/.config/terminator/config ~/.config/terminator/config
    ln -sf ~/git/DotFiles/.tmux.conf ~/.tmux.conf
    ln -sf ~/git/DotFiles/.gitconfig ~/.gitconfig
    mkdir wallpaper
    ln -sf ~/git/DotFiles/wallpaper/* ~/wallpaper
    mkdir .local/share/fonts
    cp -r ~/git/DotFiles/.local/share/fonts/ ~/.local/share/fonts
    mv ~/.config/nvim{,.bak}
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    cd ~/wallpaper && mkdir wallpaper-drive && cd wallpaper-drive && wget https://drive.google.com/file/d/1GC5mJHJsalAbE9mIRFUqP-9knfNU1Ykr/view?usp=drive_link
}

ask_confirmation() {
    read -p "$1 (y/n): " response
    case "$response" in
        [yY])
            links
            return 0 # Conferma
            ;;
        *)
            return 1 # Non conferma
            ;;
    esac
}

echo "Hai già installato tutti i pacchetti?"
if ask_confirmation "Confermi?"; then
    echo "Fatto!"
else
    echo "Non hai confermato."
fi
