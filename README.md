# .Config

.Config, my config files

## Command

mkdir ~/.local/share/fonts
git clone <https://github.com/pacchio1/DotFiles.git>
mv DotFiles/* ..

### tmux dracula

git clone <https://github.com/dracula/tmux.git>
mv tmux/* .tmux
ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~/

yay -S vscodium-bin

## Pacchetti

git i3 i3status i3status neovim tmux alacritty bat fzf exa nitrogen

## Repo

### ![Lazy vim](https://www.lazyvim.org/)

mv ~/.config/nvim{,.bak}

git clone <https://github.com/LazyVim/starter> ~/.config/nvim

rm -rf ~/.config/nvim/.git

### Tmux Plugin

git clone <https://github.com/tmux-plugins/tpm> ~/.tmux/plugins/tpm

tmux source ~/.tmux.conf

prefix + I per installare

## Other
