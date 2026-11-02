#!/bin/bash
# Restore estensioni GNOME + impostazioni dconf
# Dopo il restore riloggati o riavvia GNOME (Alt+F2 -> r)

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Restore impostazioni dconf ..."
if [ -f "$DIR/settings.dconf" ]; then
    dconf load /org/gnome/shell/extensions/ < "$DIR/settings.dconf"
    echo "[*] dconf caricato"
else
    echo "[!] settings.dconf non trovato in $DIR"
fi

echo "[*] Restore codice estensioni ..."
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
if [ -d "$DIR/extensions" ]; then
    cp -a "$DIR/extensions/." "$HOME/.local/share/gnome-shell/extensions/"
    echo "[*] Estensioni copiate in ~/.local/share/gnome-shell/extensions/"
else
    echo "[!] Cartella extensions/ non trovata in $DIR"
fi

echo "[*] Fatto. Riloggati (o Alt+F2 -> r) per applicare le estensioni."
