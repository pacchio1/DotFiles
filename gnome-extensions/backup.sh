#!/bin/bash
# Backup estensioni GNOME + impostazioni dconf
# Usa lo stesso schema di Extension Manager (impostazioni + codice)

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Backup impostazioni dconf (/org/gnome/shell/extensions/) ..."
dconf dump /org/gnome/shell/extensions/ > "$DIR/settings.dconf"

echo "[*] Backup codice estensioni utente ..."
rm -rf "$DIR/extensions"
mkdir -p "$DIR/extensions"
if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
    cp -a "$HOME/.local/share/gnome-shell/extensions/." "$DIR/extensions/"
    echo "[*] Copiate estensioni da ~/.local/share/gnome-shell/extensions/"
else
    echo "[!] Nessuna cartella estensioni trovata"
fi

echo "[*] Backup completato in: $DIR"
echo "    - settings.dconf (impostazioni)"
echo "    - extensions/ (codice estensioni installate)"
