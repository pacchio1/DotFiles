cd /var/home/mark/Templates
touch note.md
touch text.txt
# per togliere logo
ujust toggle-user-motd
ujust devmod
ujust dx-group

# Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Stato sistema e update
rpm-ostree status
ujust update
flatpak update

reboot

#messo bg

## Exstension

Quick close in overview
Advanced media controller #@Sanjai.com
alphabetical app grid
quick setting audio control

## Flatpak 

Zen
Zed
Dconf
OnlyOffice
Obsidian
Telegram
Discord
DBeaver Community
Spotify
Gear Lever
Web App Hub
zap
burp suite
wireshark

## Dconf
week-start-day -> "monday"
temperature-unit -> centigrade

### wheather
Turin

## Shorcut

win + sift + s -> take a screenshot interactlivy

### OTHER

Opencode -> curl -fsSL https://opencode.ai/install | bash
sdkman -> curl -s "https://get.sdkman.io" | bash

brew install npm -> npm config set min-release-age=30 --location=user

# Distrobox / Toolbox
distrobox create --name dev --image fedora:latest
toolbox create

# Dotfiles versionati
chezmoi init


#### YARN
npm install --global yarn@1
yarn --version   # verifica installazione
corepack enable
corepack prepare yarn@stable --activate
yarn set version berry
vim ~/.yarnrc.yml 
npmMinimalAgeGate: 43200

## sdk 

sdk install 21.0.11-amzn
sdk install 17.0.20-amzn
sdk install 26.0.2-amzn
