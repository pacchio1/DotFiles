# Port Linux / GNOME del tray opencode

## Cosa fa
Replica su Linux (estensione GNOME Shell) tutti i comportamenti estratti da
`src/OpencodeTray.cs` senza toccare la logica dell'app opencode.

## Architettura
- **Plugin** (`plugin/opencode-tray.js`): **invariato**. Continua a fare POST su `127.0.0.1:47110`.
- **Listener** (`listener/opencode-tray-listener.py`): ascolta la porta, scrive `/tmp/opencode-tray-state.json`.
- **Estensione** (`extension.js`): indicatore nella panel (sinistra dell'orologio), menu con stati, costi, progetti, toggle, exit.

## Comportamenti estratti da OpencodeTray.cs
- Icona colorata: nero (idle), verde (working), giallo (attention)
- Menu: stato + numero istanze, stima costi, elenco progetti (attivi/fermi), azzera costi, info costi
- Toggle: popup, suono, flash, avvia con sessione
- Apri cartelle: configurazione opencode, installazione, configurazione tray
- Exit / disattivazione
- Lettura costi da `~/.cache/opencode/models.json` (stesso path Linux)
- File di stato atomico (`/tmp/...`) per non perdere i totali al riavvio

## Installazione rapida
```bash
# 1. Copia l'estensione
mkdir -p ~/.local/share/gnome-shell/extensions/opencode-tray@local
cp -r gnome-extension/* ~/.local/share/gnome-shell/extensions/opencode-tray@local/
chmod +x ~/.local/share/gnome-shell/extensions/opencode-tray@local/listener/*.py

# 2. Avvia listener (in background)
python3 ~/.local/share/gnome-shell/extensions/opencode-tray@local/listener/opencode-tray-listener.py &

# 3. Ricarica GNOME Shell (Alt+F2 -> r su X11; su Wayland disconnetti e rientra)
# 4. Attiva estensione con GNOME Tweaks / Extensions o via gsettings
```

## Note
- Per mettere l'indicatore esattamente a sinistra dell'orologio: `Main.panel.addToStatusArea(..., 0, "right")`; se l'orologio è nel centro potrebbe servire un indice diverso a seconda della versione GNOME.
- La stima costi completa (token, proiezioni settimanali/mensili) richiede il parsing del campo `models` inviato dal plugin; il script `cost-info-window.py` mostra lo stato attuale come primo passo.
- Non sono stati aggiunti file alla logica di `opencode` o al plugin JS (come richiesto).
