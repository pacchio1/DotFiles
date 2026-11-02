# GNOME Shell Extensions — Backup / Versione

Questo folder segue lo schema di **Extension Manager** (impostazioni + codice):
- `settings.dconf` → configurazioni delle estensioni (`dconf dump /org/gnome/shell/extensions/`)
- `extensions/` → codice delle estensioni installate in `~/.local/share/gnome-shell/extensions/`

## Uso

```bash
# Backup (dopo aver installato/modificato estensioni)
./gnome-extensions/backup.sh

# Restore su altro PC / dopo reinstallazione
./gnome-extensions/restore.sh
# Poi riloggati o riavvia GNOME (Alt+F2 -> r)
```

## Note
- Le estensioni installate da `extensions.gnome.org` possono anche essere reinstallate manualmente o tramite Extension Manager; questo folder serve per **versionare** le modifiche fatte (impostazioni personalizzate + eventuali estensioni locali/custom).
- Per sincronizzare anche la lista delle estensioni installate tra dispositivi, si può usare l'estensione **Extensions Sync** (`extensions.gnome.org/extension/1486/`).
