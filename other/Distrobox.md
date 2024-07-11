#Distrobox

## 1 install distrobox e podman
sudo dnf install distrobox podman

## 2 Ubuntu e Arch
distrobox create -i archlinux/archlinux --name archbtw #Arch
distrobox create --name ubuntu --image ubuntu #Ubuntu

## 3 Abilitare Pacman su Arch e aggiornamenti
sudo pacman-key --init
sudo pacman -Syu

## 4 Package per aur
sudo pacman -S git vim base-devel go

## 5 copile faster
sudo vim /etc/makepkg.conf
"Makeflas ="-j5""

## 6 AUR e yay
cd
mkdir .distrobox
cd .distrobox
mkdir arch
cd arch
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

## Nala
sudo apt install nala



