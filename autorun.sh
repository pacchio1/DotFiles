###### Install Package First ######
links(){
    ln -sf ~/git/DotFiles/bashrc/daily.sh ~/.bashrc
    ln -sf ~/git/DotFiles/.config/i3/config ~/.config/i3/config
    ln -sf ~/git/DotFiles/.config/i3status/config ~/.config/i3status/config
    ln -sf ~/git/DotFiles/.config/terminator/config ~/.config/terminator/config
    ln -sf ~/git/DotFiles/.tmux.conf ~/.tmux.conf
    ln -sf ~/git/DotFiles/.gitconfig ~/.gitconfig
    mkdir .local/share/fonts
    cp -r ~/git/DotFiles/.local/share/fonts/ ~/.local/share/fonts
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
    echo "hai confermato."
else
    echo "Non hai confermato."
fi
