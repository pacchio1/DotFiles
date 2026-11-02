#!/bin/bash
# Backup estensioni GNOME + impostazioni dconf
# Usa lo stesso schema di Extension Manager (impostazioni + codice)

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Backup impostazioni dconf (/org/gnome/shell/extensions/) ..."
dconf dump /org/gnome/shell/extensions/ > "$DIR/settings.dconf"

echo "[*] Backup codice estensioni utente ..."
rm -rf "$DIR/extensions"
mkdir -p "$DIR/extensions"
# Escludi queste estensioni (solo config in settings.dconf)
SKIP="appindicator* apps-menu* bazaar* blur-my-shell* caffeine* dash-to-dock* gradia* gsconnect* launch-new-instance* places-menu* search-light* window-list*"

if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
    for ext in "$HOME/.local/share/gnome-shell/extensions/"*; do
        [ -d "$ext" ] || continue
        base=$(basename "$ext")
        skip=0
        for s in $SKIP; do
            case "$base" in $s) skip=1; break ;; esac
        done
        if [ $skip -eq 1 ]; then
            echo "    [skip] $base"
            continue
        fi
        cp -a "$ext" "$DIR/extensions/"
    done
    echo "[*] Copiate estensioni (escluse quelle in .gitignore)"
else
    echo "[!] Nessuna cartella estensioni trovata"
fi

echo "[*] Backup completato in: $DIR"
echo "    - settings.dconf (impostazioni)"
echo "    - extensions/ (codice estensioni installate)"
