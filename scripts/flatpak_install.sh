#!/usr/bin/env bash
# Script per installare solo le app Flatpak utili (senza runtime superflui)

echo "🔍 Controllo Flathub..."
if ! flatpak remotes | grep -q flathub; then
    echo "➕ Aggiungo Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo "🚀 Inizio installazione Flatpak..."

apps=(
    app.zen_browser.zen
    com.brave.Browser
    com.discordapp.Discord
    com.mattjakeman.ExtensionManager
    com.spotify.Client
    com.usebruno.Bruno
    eu.betterbird.Betterbird
    io.github.getnf.embellish
    net.nokyan.Resources
    org.onlyoffice.desktopeditors
    org.telegram.desktop
)

for app in "${apps[@]}"; do
    echo "📦 Installo $app ..."
    flatpak install -y flathub "$app"
done

echo "✅ Tutte le applicazioni sono state installate!"
