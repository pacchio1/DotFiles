###### Install Package First ######
links() {
	cd

	#bash
	ln -sf ~/git/DotFiles/bashrc/daily.sh ~/.bashrc
	thouch ~/.bash_aliases
	mkdir ~/.config/fish
	ln -sf ~/git/DotFiles/bashrc/.bash_aliases ~/.bash_aliases
	ln -sf ~/git/DotFiles/.config/fish/config.fish ~/.config/fish/config.fish

	#i3
	mkdir ~/.config/i3
	mkdir ~/.config/i3status
	ln -sf ~/git/DotFiles/.config/i3/config ~/.config/i3/config
	ln -sf ~/git/DotFiles/.config/i3/mine.conf ~/.config/i3/mine.conf
	ln -sf ~/git/DotFiles/.config/i3status/config ~/.config/i3status/config

	#terminator
	mkdir ~/.config/terminator
	ln -sf ~/git/DotFiles/.config/terminator/config ~/.config/terminator/config

	#git
	ln -sf ~/git/DotFiles/.gitconfig ~/.gitconfig

	# fonts
	mkdir ~/.local/share/fonts
	cp -r ~/git/DotFiles/.local/share/fonts/ ~/.local/share/fonts
	cp -r ~/git/DotFiles/.gtkrc-2.0.mine ~/.gtkrc-2.0.mine

	#tmux
	ln -sf ~/git/DotFiles/.tmux.conf ~/.tmux.conf

	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	#neofetch
	mkdir ~/.config/neofetch
	ln -sf ~/git/DotFiles/.config/neofetch/config.conf ~/.config/neofetch/config.conf

	#kitty
	mkdir ~/.config/kitty

	cd ~/git/DotFiles/kitty-master
	cp dracula.conf diff.conf ~/.config/kitty/
	echo "include dracula.conf" >>~/.config/kitty/kitty.conf

}
wallpa() {
	mkdir ~/wallpaper
	cd ~/wallpaper
	git clone https://github.com/NotPacchio/WallPaper.git
}
nvimconf() {
	# Uninstall
	rm -rf ~/.config/nvim
	rm -rf ~/.local/share/nvim
	#nvim
	# required
	mv ~/.config/nvim{,.bak}

	# optional but recommended
	mv ~/.local/share/nvim{,.bak}
	mv ~/.local/state/nvim{,.bak}
	mv ~/.cache/nvim{,.bak}
	#nvchad
	#git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim

	#lazy git
	git clone https://github.com/LazyVim/starter ~/.config/nvim

	rm -rf ~/.config/nvim/.git

	nvim
	# se devo muovere la cartella config di nvim farlo dopo questo commento
	#ln -sf ~/git/DotFiles/.config/nvim ~/.config/nvim
	#se avro personalizazioni

}
custom_theme() {

	dotf
	#dracula + papirus: icons and themes
	tar -xvf dracula_theme.tar.gz
	cp -r .icons/* ~/.icons
	cp -r .themes/* ~/.themes

	#command on https://www.gnome-look.org/p/1687249/
	gsettings set org.gnome.desktop.interface gtk-theme Dracula
	gsettings set org.gnome.desktop.wm.preferences theme Dracula

	#setup per flatpak solo per gnome
	#sudo flatpak override --filesystem=~/.

	#extension
	gitf
	git clone https://github.com/NotPacchio/gnome-extension.git /home/mark/.local/share/gnome-shell/extensions

	#gnome-tweaks
	gnome-tweaks
}
ask_confirmation() {
	read -p "$1 (y/N): " response
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
ask_confirmation_nvim() {
	read -p "$1 (y/N): " response
	case "$response" in
	[yY])
		nvimconf
		return 0 # Conferma
		;;
	*)
		return 1 # Non conferma
		;;
	esac
}
ask_confirmation_wallpaper() {
	read -p "$1 (y/N): " response
	case "$response" in
	[yY])
		wallpa
		return 0 # Conferma
		;;
	*)
		return 1 # Non conferma
		;;
	esac
}

customization() {
	read -p "$1 (y/N): " response
	case "$response" in
	[yY])
		custom_theme
		return 0 # Conferma
		;;
	*)
		return 1 # Non conferma
		;;
	esac
}

echo "Hai già installato tutti i pacchetti? (specificati nel readme)"
eccho "\n git neovim neofetch tmux kitty bat fzf exa fish locate"
if ask_confirmation "Confermi?"; then
	echo "Fatto!"
else
	echo "Non hai confermato."
fi
echo "desideri configurare neovim?"
if ask_confirmation_nvim "Confermi?"; then
	echo "Fatto!"
else
	echo "Non hai confermato."
fi
echo "desideri anche gli sfondi"
if ask_confirmation_wallpaper "Confermi?"; then
	echo "Fatto!"
else
	echo "Non hai confermato."
fi
echo "desideri anche icons e themes? (gnome)"
if customization "Confermi?"; then
	echo "Fatto!"
else
	echo "Non hai confermato."
fi
