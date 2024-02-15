## Indeciso

terminator, zsh

### NvChad

git clone <https://github.com/NvChad/NvChad> ~/.config/nvim --depth 1 && nvim

### HoMyZsh

sh -c "$(curl -fsSL <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"

### YaY

git clone <https://aur.archlinux.org/yay.git>
cd yay
makepkg -si


## Repo

### Lazy vim

![lazyvim](https://www.lazyvim.org/)

mv ~/.config/nvim{,.bak}

git clone <https://github.com/LazyVim/starter> ~/.config/nvim

rm -rf ~/.config/nvim/.git

### Tmux Plugin

git clone <https://github.com/tmux-plugins/tpm> ~/.tmux/plugins/tpm

tmux source ~/.tmux.conf

## Other
