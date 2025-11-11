#!/usr/bin/env bash
# Script per installare tutti i Flatpak elencati
# Funziona su Fedora 43 o versioni simili

# Assicurati che il remote Flathub sia aggiunto
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
    org.freedesktop.Platform//24.08
    org.freedesktop.Platform//25.08
    org.freedesktop.Platform.GL.default//24.08
    org.freedesktop.Platform.GL.default//24.08extra
    org.freedesktop.Platform.GL.default//25.08
    org.freedesktop.Platform.GL.default//25.08-extra
    org.freedesktop.Platform.codecs-extra//25.08-extra
    org.freedesktop.Platform.ffmpeg-full//24.08
    org.freedesktop.Platform.openh264//2.5.1
    org.gnome.Platform//48
    org.gnome.Platform//49
    org.onlyoffice.desktopeditors
    org.telegram.desktop
)

for app in "${apps[@]}"; do
    echo "📦 Installo $app ..."
    flatpak install -y flathub "$app"
done

echo "✅ Tutti i Flatpak sono stati installati!"
