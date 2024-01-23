#!/bin/bash

sudo apt install git terminator  i3 i3status i3status neovim
mkdir ~/.local/share/fonts
git clone <https://github.com/NvChad/NvChad> ~/.config/nvim --depth 1 && nvim
git clone <https://github.com/pacchio1/Config.git> ~/
