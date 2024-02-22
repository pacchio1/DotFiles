###### Install Package First ######
links(){
    ln -sf ~/git/DotFiles/bashrc/daily.sh ~/.bashrc
    ln -sf ~/git/DotFiles/bashrc/.bash_aliases ~/.bash_aliases
    mkdir ~/.config/i3
    mkdir ~/.config/i3status
    ln -sf ~/git/DotFiles/.config/i3/config ~/.config/i3/config
    ln -sf ~/git/DotFiles/.config/i3status/config ~/.config/i3status/config
    ln -sf ~/git/DotFiles/.config/terminator/config ~/.config/terminator/config
    ln -sf ~/git/DotFiles/.tmux.conf ~/.tmux.conf
    ln -sf ~/git/DotFiles/.gitconfig ~/.gitconfig
    cd && mkdir wallpaper
    mkdir .local/share/fonts
    cp -r ~/git/DotFiles/.local/share/fonts/ ~/.local/share/fonts
    cp -r ~/git/DotFiles/.gtkrc-2.0.mine ~/.gtkrc-2.0.mine


    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    cd ~/wallpaper && mkdir wallpaper-drive && cd wallpaper-drive && wget https://drive.google.com/file/d/1GC5mJHJsalAbE9mIRFUqP-9knfNU1Ykr/view?usp=drive_link

    #nvim
    mv ~/.config/nvim{,.bak}

    #lazy git
    #git clone https://github.com/LazyVim/starter ~/.config/nvim
    #rm -rf ~/.config/nvim/.git

    #nvchad
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim

    # Uninstall
    #rm -rf ~/.config/nvim
    #rm -rf ~/.local/share/nvim


    # se devo muovere la cartella config di nvim farlo dopo questo commento
    #ln -sf ~/git/DotFiles/.config/nvim ~/.config/nvim
    #se avro personalizazioni

    #kitty
    mkdir ~/.config/kitty

    cd ~/git/DotFiles/kitty-master
    cp dracula.conf diff.conf ~/.config/kitty/
    echo "include dracula.conf" >> ~/.config/kitty/kitty.conf

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
