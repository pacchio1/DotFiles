# TODO

## Da fare
- [ ] Personalizzare lo script per installazione tipo dispositivo es rasp / daily / vm ....

## Fatto (2026-09-14, verificato in Docker Fedora)
- [x] Fix typo in `autorun.sh` (`thouch` → `touch`, `eccho` → `echo`, `Ghosty` → `ghostty`, `logut` → `logout`)
- [x] Sostituiti path hardcoded `/home/mark/` con `$HOME` (autorun.sh, daily.sh, riordina.sh, riordina.php)
- [x] `credential.helper = store` → `cache` (sicurezza, niente credenziali in plaintext)
- [x] Rimosso side-effect `git config --global` da `daily.sh` (sovrascriveva il .gitconfig versionato a ogni shell)
- [x] Aggiunto `set -euo pipefail` e gestione errori; rimossi `source ~/.bashrc` fragili dalle funzioni
- [x] Consolidate 4 funzioni `ask_confirmation*` in una sola parametrizzata
- [x] Guard `BASH_SOURCE` in `autorun.sh`: si può fare `source` senza eseguire i prompt
- [x] Fix typo `firefoxhttps://` in i3 config
- [x] Rimosso duplicato `tar` in `riordina.sh`; aggiunte estensioni `tar.xz/tgz/xz` a `riordina.php`
- [x] Rimosso fish config e `.bash_profile` (non più usati)
- [x] `.gitignore` ampliato; screenshot PNG mantenuti nel repo
- [x] README: aggiunti capitoli Script Disponibili, Struttura File, Fix Applicati, Sicurezza, Contributing, License
