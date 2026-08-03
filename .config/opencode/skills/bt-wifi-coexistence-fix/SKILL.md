---
name: bt-wifi-coexistence-fix
description: Use when diagnosing and fixing Bluetooth audio stutter/lag that only appears during WiFi load (speedtest, downloads, updates) on a Realtek combo chip (rtw89 / RTL8852CE, RTL8852BE, etc.) or similar WiFi/BT coexistence issues, especially on immutable Linux (Bluefin, Bazzite, Fedora Atomic/Silverblue). Identify the firmware regression, then apply a persistent immutable-safe firmware workaround. Trigger keywords: audio bluetooth, lag, stutter, crackle, rtw89, rtl8852ce, rtl8852b, coexistence, a2dp, aptx, 2.4GHz, firmware.
---

# Fix BT/WiFi coexistence audio stutter

Quando l'audio Bluetooth lagga o stuttera **solo quando il WiFi è sotto carico**
(speedtest, download pesanti, update) su un chip combo WiFi+BT Realtek, il
problema è quasi sempre una **regressione di firmware** che rompe la
"coexistence" tra le due radio, che condividono i bus interni del chip.

L'obiettivo: confermare il problema, individuare il firmware regredito, e
applicare un workaround **persistente** senza rompere l'immutabilità di un
sistema atomico (i fix vanno in `/etc` e nei kargs, mai in `/usr/lib`).

## Quando usarla
- Usa questo flusso quando il sintomo è "audio BT instabile solo con WiFi attivo
  sotto carico" su un chip combo Realtek.
- Su sistemi atomici/immutabili (Bluefin, Bazzite, Silverblue): applica i fix in
  `/etc` (persistente) e tramite kargs (`rpm-ostree` / `bootc`). Evita layering
  e modifiche a `/usr/lib` (read-only).
- NON usarla per problemi BT con WiFi stabile/spento, per problemi di codec
  (si risolvono nella config di WirePlumber/PipeWire), o per guasti fisici del
  modulo: sono percorsi diversi.

## Passi
1. **Raccogli lo stato senza saltare a conclusioni.**
   - Firmware WiFi e BT attualmente caricati:
     - `pkexec dmesg | grep -iE 'loaded firmware|Firmware version|hci'`
   - Path di ricerca firmware (deve essere vuoto se di fabbrica):
     - `cat /sys/module/firmware_class/parameters/path`
   - Kargs attivi:
     - `grep -o 'firmware_class[^ ]*' /proc/cmdline`
   - Elenca i file firmware disponibili in `/usr/lib/firmware/<driver>/`.

2. **Conferma che sia firmware/coexistence, non codec.**
   - Guarda i log di WirePlumber/audio al momento del lag:
     - `pkexec journalctl --user -u wireplumber | grep -iE 'underrun|missing|completion|timeout'`
   - Messaggio tipico di conferma:
     `spa.bluez5.sink.media: Missing completion reports for packet ...
     Bluetooth adapter firmware bug?` → il controller BT non inoltra i pacchetti
     A2DP in tempo sotto carico: è firmware, non codec.
   - Controlla comunque il codec attivo (`wpctl inspect`) per esclusione.

3. **Identifica il firmware regredito (cerca la regressione, non inventarla).**
   - Passo decisivo. Attenzione: nel caso rtw89 la regressione **non** è nel
     firmware BT, ma nel **firmware WiFi condiviso** (anche se il sintomo appare
     sul lato BT).
   - Compara le versioni disponibili:
     - `pkexec modinfo <driver> | grep firmware`
     - Estrai i file `.xz` (`unxz -c`) e confronta gli header/versioni.
   - Cerca il bug noto per chip + sintomo: usa `websearch` o i log kernel.
   - Caso rtw89 (RTL8852CE): `rtw8852c_fw-2.bin` / `rtw8852c_fw-1.bin` (0.27.x
     nuovi) hanno una regressione di coexistence (Bugzilla #2349675);
     `rtw8852c_fw.bin` (0.27.56.14, da kernel 6.11) è stabile.
   - Errore da evitare: modificare il firmware **BT** non aiuta; il colpevole è
     il firmware del **modulo WiFi** condiviso.

4. **Comprendi come il driver carica il firmware** (per scegliere il workaround).
   - Il driver rtw89 prova i nomi in formato decrescente e usa il primo che si
     carica: `rtw8852c_fw-2.bin -> rtw8852c_fw-1.bin -> rtw8852c_fw.bin`.
     Accetta anche firmware "legacy" (senza header MFW).
   - Verifica dal sorgente del driver (download del `.c` se non installato):
     cerca `fw_format_max`, `fw_basename`, `rtw89_early_fw_feature_recognize`,
     `rtw89_fw_get_filename`.

5. **Applica il workaround persistente (immutable-safe).**
   - Fai cercare al kernel prima `/etc/firmware` (karg persistente, in coda
     al boot): `rpm-ostree kargs --append="firmware_class.path=/etc/firmware"`
     (su `bootc`: usa il relativo comando kargs).
   - Inietta il firmware **stabile** con il nome dei firmware regrediti in
     `/etc/firmware/<subdir>/`:
     - es: `unxz -c /usr/lib/firmware/rtw89/rtw8852c_fw.bin.xz > /etc/firmware/rtw89/rtw8852c_fw-2.bin`
     - ripeti per ogni nome (`-1`, `-2`): il contenuto è sempre lo stabile.
   - Essendo `/etc` cercato per primo (grazie al karg), il driver carica i nomi
     regrediti ma con il contenuto stabile.

6. **Misure complementari (opzionali, riducono il carico di coexistence).**
   - Disabilita l'USB autosuspend del controller BT con una regola udev
     (i controller BT Realtek sono spesso USB `0bda:886c` e stutterano se
     sospesi sotto carico).
   - Forza il WiFi in banda 5GHz: `nmcli connection modify <conn> wifi.band a`
     (evita la 2.4GHz, dove la coexistence è peggiore).
   - Opzionale: `options <driver> disable_ps_mode=1` in `/etc/modprobe.d/`.

## Verifiche
Dopo `systemctl reboot`:
- `cat /sys/module/firmware_class/parameters/path` → `/etc/firmware`
- `pkexec dmesg | grep -E 'Firmware version'` → la versione stabile
  (NON quella regredita).
- `cat /sys/bus/usb/devices/<BT>/power/control` → `on` (se applicato)
- Rifai il test reale: cuffie BT + speedtest o download pesante, niente stutter.

## Errori noti / Ostacoli
- **Versione ancora regredita dopo il reboot** → il workaround non è passato
  perché il driver lo ha preso dall'initramfs. Ricarica con `pkexec dracut
  --force` o verifica che il karg sia attivo nel boot corrente
  (`cat /proc/cmdline`).
- **Ha peggiorato dopo il primo tentativo su firmware BT** → il target è
  sbagliato: il driver giusto è quello del **WiFi condiviso**, non del BT.
  Ripristina e prova l'altro target.
- **Sysfs reset a ogni boot** (es. scrivere `firmware_class.path` via `/sys`):
  non è persistente. Usa un karg (`rpm-ostree`) invece di una scrittura sysfs
  manuale.
- **`/usr/lib` read-only su atomico**: non cercare di modificarlo; lavora in
  `/etc` e nei kargs.
- **Gli aggiornamenti kernel** possono ripristinare i file firmware: dopo un
  update, riapplica il workaround e verifica la versione.

## Esempio (generico)
Un laptop con chip combo Realtek con audio BT a scatti durante uno speedtest.
I log WirePlumber mostrano `Missing completion reports for packet ...
firmware bug?`. L'analisi identifica una regressione nel firmware WiFi
(0.27.129.4) e il base 0.27.56.14 stabile. Workaround: karg
`firmware_class.path=/etc/firmware` + iniezione dello stabile nei nomi regressi
in `/etc/firmware/<drv>/`, reboot, verifica della versione e test carico.