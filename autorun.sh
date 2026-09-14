#!/bin/bash
set -euo pipefail

###### Install Package First ######
links() {
	cd "$HOME"

	#bash
	ln -sf "$HOME/git/DotFiles/bashrc/daily.sh" "$HOME/.bashrc"
	touch "$HOME/.bash_aliases"
	ln -sf "$HOME/git/DotFiles/bashrc/.bash_aliases" "$HOME/.bash_aliases"

	# i3
	mkdir -p "$HOME/.config/i3"
	mkdir -p "$HOME/.config/i3status"
	ln -sf "$HOME/git/DotFiles/.config/i3/config" "$HOME/.config/i3/config"
	ln -sf "$HOME/git/DotFiles/.config/i3/mine.conf" "$HOME/.config/i3/mine.conf"
	ln -sf "$HOME/git/DotFiles/.config/i3status/config" "$HOME/.config/i3status/config"

	# terminator
	mkdir -p "$HOME/.config/terminator"
	ln -sf "$HOME/git/DotFiles/.config/terminator/config" "$HOME/.config/terminator/config"

	# git
	ln -sf "$HOME/git/DotFiles/.gitconfig" "$HOME/.gitconfig"

	# fonts
	mkdir -p "$HOME/.local/share/fonts"
	cp -r "$HOME/git/DotFiles/.local/share/fonts/" "$HOME/.local/share/fonts/" 2>/dev/null || true
	cp -r "$HOME/git/DotFiles/.gtkrc-2.0.mine" "$HOME/.gtkrc-2.0.mine" 2>/dev/null || true

	# tmux
	ln -sf "$HOME/git/DotFiles/.tmux.conf" "$HOME/.tmux.conf"

	if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
		git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
	fi

	# neofetch
	mkdir -p "$HOME/.config/neofetch"
	ln -sf "$HOME/git/DotFiles/.config/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"

	# ghostty
	mkdir -p "$HOME/.config/ghostty"
	ln -sf "$HOME/git/DotFiles/.config/ghostty/config" "$HOME/.config/ghostty/config"

	# opencode (i file tracciati; node_modules/package*.json restano locali)
	mkdir -p "$HOME/.config/opencode"
	ln -sf "$HOME/git/DotFiles/.config/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
	ln -sf "$HOME/git/DotFiles/.config/opencode/.gitignore" "$HOME/.config/opencode/.gitignore"
	ln -sf "$HOME/git/DotFiles/.config/opencode/README.md" "$HOME/.config/opencode/README.md"
	ln -sf "$HOME/git/DotFiles/.config/opencode/skills" "$HOME/.config/opencode/skills"
}
wallpa() {
	mkdir -p "$HOME/wallpaper"
	cd "$HOME/wallpaper"
	git clone https://github.com/NotPacchio/WallPaper.git 2>/dev/null || true
	git clone https://github.com/AngelJumbo/gruvbox-wallpapers.git 2>/dev/null || true
}
nvimconf() {
	# Uninstall
	rm -rf "$HOME/.config/nvim"
	rm -rf "$HOME/.local/share/nvim"
	# backup existing if present
	mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak" 2>/dev/null || true
	mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak" 2>/dev/null || true

	# lazy git
	if [ ! -d "$HOME/.config/nvim" ]; then
		git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
	fi
	rm -rf "$HOME/.config/nvim/.git"

	nvim
	cp -r "$HOME/git/DotFiles/.config/neovim/nvim/" "$HOME/.config/nvim/lua/plugins/" 2>/dev/null || true
}
# custom_theme() {
# 	source ~/.bashrc

# }
daily() {
	ln -sf "$HOME/git/DotFiles/bashrc/daily.sh" "$HOME/.bashrc"
}

ask_confirmation() {
	local prompt="$1"
	local action="$2"
	local response=""
	read -rp "$prompt (y/N): " response || response=""
	case "$response" in
	[yY])
		$action
		return 0
		;;
	*)
		return 1
		;;
	esac
}

# customization() {
# 	read -p "$1 (y/N): " response
# 	case "$response" in
# 	[yY])
# 		custom_theme
# 		return 0 # Conferma
# 		;;
# 	*)
# 		return 1 # Non conferma
# 		;;
# 	esac
# }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Hai già installato tutti i pacchetti? (specificati nel readme)/have you installed all packages?"
	printf '\n git neovim neofetch tmux kitty bat fzf exa locate\n'
	if ask_confirmation "Confermi?" links; then
		echo "Fatto! / Done!"
	else
		echo "Non hai confermato. / Not Done !"
	fi
	echo "desideri configurare neovim? / do you want to configure neovim?"
	if ask_confirmation "Confermi?" nvimconf; then
		echo "Fatto! / Done!"
	else
		echo "Non hai confermato. / Not Done !"
	fi
	echo "desideri anche gli sfondi / wallpapers?"
	if ask_confirmation "Confermi?" wallpa; then
		echo "Fatto! / Done!"
	else
		echo "Non hai confermato. / Not Done !"
	fi
	echo "desideri anche icons e themes?/ do you want to personalize icons and themes?"
	# if customization "Confermi?" ; then
	# 	echo "Fatto! / Done!"
	# else
	# 	echo "Non hai confermato. / Not Done !"
	# fi
	echo "vuoi configurare anche il daily? / do you want to configure the daily (bashrc)?"
	if ask_confirmation "Confermi?" daily; then
		echo "Fatto! / Done!"
	else
		echo "Non hai confermato. / Not Done !"
	fi
	echo "è consigliato un logout"
fi


