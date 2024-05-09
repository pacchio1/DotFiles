# OTHER

## Distro Repo expander

## YaY - Pacman

git clone <https://aur.archlinux.org/yay.git>

cd yay

makepkg -si

-------------------------

## copr - fedora

#### DNF Configuration

##### sudo nano /etc/dnf/dnf.conf

<p>fastestmirror=True

max_parallel_downloads=10

defaultyes=True

keepcache=True</p>

#### Rpm fusion -> https://rpmfusion.org/Configuration


```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

##### Meta data

sudo dnf groupupdate core

#### Install Media Codecs

sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

------------------------

## nala - debian

echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list; wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg

sudo apt update && sudo apt install nala

-------------------------

## flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## Repo


### NvChad

git clone <https://github.com/NvChad/NvChad> ~/.config/nvim --depth 1 && nvim

### HoMyZsh

sh -c "\$(curl -fsSL <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>)"


### Lazy vim

![lazyvim](https://www.lazyvim.org/)

mv ~/.config/nvim{,.bak}

git clone <https://github.com/LazyVim/starter> ~/.config/nvim

rm -rf ~/.config/nvim/.git

### Tmux Plugin

git clone <https://github.com/tmux-plugins/tpm> ~/.tmux/plugins/tpm

tmux source ~/.tmux.conf

## Other - Get number of packet installed

### Flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## backup

#### debian / ubuntu
dpkg -l | grep ^ii | awk '{print $2}' > ~/git/DotFiles/debpacket

#### flatpak
flatpak list --columns=name

#### snap
snap list | grep -v '^$' | awk {'print $1'}
