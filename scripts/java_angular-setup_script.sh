# Aggiorna pacchetti base
apt update && apt upgrade -y

# Installa pacchetti principali (incluso zip/unzip, fondamentali per sdkman!)
apt install -y maven git npm flatpak curl zip unzip wget gpg apt-transport-https software-properties-common

# Configura Flatpak + installa Telegram e Discord
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.telegram.desktop
flatpak install -y flathub com.discordapp.Discord

# Installa Yarn via npm
npm install -g yarn

# Installa SDKMAN! e aggiungi l'inizializzazione a .bashrc di root
# Usiamo la modalità CI (Continuous Integration) per un'installazione non interattiva
curl -s "https://get.sdkman.io?ci=true" | bash

# Aggiunge le righe di inizializzazione alla fine del .bashrc di root
# Questo farà in modo che SDKMAN! sia disponibile quando la shell bash viene avviata
echo "" >> /root/.bashrc
echo "# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!" >> /root/.bashrc
echo "export SDKMAN_DIR=\"/root/.sdkman\"" >> /root/.bashrc
echo "[[ -s \"/root/.sdkman/bin/sdkman-init.sh\" ]] && source \"/root/.sdkman/bin/sdkman-init.sh\"" >> /root/.bashrc

# Installa Visual Studio Code (repo ufficiale Microsoft)
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install -y code
rm -f packages.microsoft.gpg

# Pulizia finale (opzionale)
apt clean
rm -rf /var/lib/apt/lists/*