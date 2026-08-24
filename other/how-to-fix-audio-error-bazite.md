# Fix audio Bluetooth + crash di sistema (freeze/riavvio) su Bluefin/Bazzite

> Due problemi distinti, documentati qui insieme perché condivisi lo stesso
> hardware:
>
> 1. **Lag audio BT sotto carico rete** → regressione firmware WiFi rtw89
>    (Bugzilla #2349675).
> 2. **Freeze/riavvio del sistema** → errore interno del controller NVMe Micron
>    2550, scatenato da sospensione s2idle e I/O intenso.

---

## Hardware

- **Laptop:** Dell Inspiron 16 5645
- **Chip WiFi+BT:** Realtek RTL8852CE (WiFi `rtw89_8852ce`, BT USB `0bda:886c`)
- **NVMe:** Micron 2550 1024GB (firmware `25500202`, `apsta=1` → APST attivo)
- **CPU/GPU:** AMD Ryzen 7 8840U + Radeon 780M (solo `s2idle`, niente S3)
- **Sistema:** Bluefin (immutabile, basato su Fedora Atomic)

## Sintomo

Collegando delle cuffie **Bluetooth** (A2DP), durante un utilizzo intensivo della
rete (speedtest, download pesanti, `brew install`, `rpm-ostree upgrade`) l'audio
**lagga / stuttera** in modo quasi casuale. Succede anche da soli, senza rete, ma
si amplifica sotto carico.

Non è un guasto hardware: il problema è di **coexistence WiFi/BT** gestita dal
firmware del chip.

---

## Diagnosi (come ho capito cosa non andava)

Il primo tentativo, sbagliato, aveva modificato il firmware **Bluetooth**. Non
funzionava perché il problema era in un altro firmware.

Tracce chiave nei log:

```bash
pkexec journalctl --user -u wireplumber | grep 'Missing completion reports'
# -> spa.bluez5.sink.media: Missing completion reports for packet ... firmware bug?
```

Questo messaggio conferma che il controller BT non restituisce i "completion
reports" per i pacchetti audio A2DP in tempo sotto carico: il chip deve gestire
simultaneamente WiFi e BT su bus interni condivisi, e il firmware **WiFi** nuvo
rompe i tempi di coexistence.

La differenza di firmware WiFi:

| File firmware            | Versione      | Stato                       |
|--------------------------|---------------|-----------------------------|
| `rtw8852c_fw-2.bin`      | 0.27.129.4    | ❌ regressione coexistence   |
| `rtw8852c_fw-1.bin`      | 0.27.97.0     | ❌ regressione               |
| `rtw8852c_fw.bin`        | 0.27.56.14    | ✅ stabile (kernel 6.11)     |

La regressione è tracciata qui: **Bugzilla #2349675**.

Riferimento utile (post di Dre Dyson che riassume il workaround):
- <https://dredyson.com/fix-bluetooth-audio-stuttering-during-wifi-activity-on-rtl8852ce-in-under-5-minutes-actually-works-a-complete-step-by-step-quick-fix-guide-for-fedora-manjaro-and-all-linux-distros-using-the-prov/>

---

## Come funziona il caricamento del firmware rtw89

Il driver prova i nomi dal formato più nuovo al più vecchio e usa il primo
caricato:

```
rtw8852c_fw-2.bin  ->  rtw8852c_fw-1.bin  ->  rtw8852c_fw.bin
```

Su un sistema **immutabile** non possiamo cancellare i file in
`/usr/lib/firmware` (read-only). Quindi sovrascriviamo il meccanismo:

1. Il kernel, se il karg `firmware_class.path=/etc/firmware` è impostato, cerca il
   firmware **prima** in `/etc/firmware`.
2. Mettiamo in `/etc/firmware/rtw89/` dei file con il **nome** dei firmware rotti
   (`fw-2.bin`, `fw-1.bin`) ma con il **contenuto** del firmware stabile
   (`rtw8852c_fw.bin`).
3. Il driver carica quindi sempre la versione **0.27.56.14** stabile.

---

## Soluzione definitiva (script)

Script riutilizzabile, salvato in `~/fix_rtw89_fw.sh`:

```bash
#!/usr/bin/env bash
# fix_rtw89_fw.sh — Workaround persistente Bugzilla #2349675
# RTL8852CE/RTW89: la regressione nel firmware WiFi nuovo fa stutterare
# l'audio Bluetooth sotto carico rete. Forza la versione stabile 0.27.56.14.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Serve root: pkexec bash $0"; exit 1
fi

GOOD_SRC="/usr/lib/firmware/rtw89/rtw8852c_fw.bin.xz"
DST_DIR="/etc/firmware/rtw89"

mkdir -p "$DST_DIR"
for name in rtw8852c_fw-2.bin rtw8852c_fw-1.bin; do
    unxz -c "$GOOD_SRC" > "$DST_DIR/$name"
done

# karg persistente (in coda per il prossimo boot)
if ! grep -q 'firmware_class.path' /proc/cmdline; then
    rpm-ostree kargs --append="firmware_class.path=/etc/firmware"
fi
echo "Done. Reboot richiesto."
```

Eseguire con privilegi:

```bash
pkexec bash ~/fix_rtw89_fw.sh
systemctl reboot
```

> ⚠️ Su sistemi atomici usare **`pkexec`** (PolicyKit) e non `sudo` diretto.
> **Mai** `dnf install`/layering per questo tipo di workaround: `/etc` è
> persistente tra gli aggiornamenti, mentre i karg si applicano con `rpm-ostree`.

---

## Altre misure complementari (opzionali ma consigliate)

### 1. Disabilita USB autosuspend del controller BT

Il controller BT è un device USB (`0bda:886c`). Se in autosuspend si sospende
sotto carico e stutter. Regola udev persistente:

```bash
pkexec tee /etc/udev/rules.d/90-bluetooth-no-autosuspend.rules >/dev/null <<'EOF'
ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="886c", ATTR{power/control}="on"
EOF
udevadm control --reload-rules
udevadm trigger --subsystem-match=usb --action=change
```

Oppure, subito senza reboot:

```bash
echo on | pkexec tee /sys/bus/usb/devices/1-4/power/control
```

### 2. Forza il WiFi in banda 5 GHz (evita la 2.4 GHz)

La coexistence è peggiore sulla 2.4 GHz. Se il tuo AP supporta il 5 GHz,
ancora il profilo alla sola banda 5 GHz:

```bash
nmcli connection modify iliadbox-2E82B5 wifi.band a
nmcli connection up iliadbox-2E82B5
```

### 3. Disabilita il powersave del WiFi

Il potter saving produce picchi di latenza. File `/etc/modprobe.d/rtw89-coex.conf`:

```bash
options rtw89_core disable_ps_mode=1
```

---

## Verifica dopo il reboot

```bash
# 1. La sysfs del caricamento firmware deve puntare a /etc/firmware
cat /sys/module/firmware_class/parameters/path

# 2. La versione firmware WiFi caricata deve essere la stabile
pkexec dmesg | grep -E 'loaded firmware rtw89|Firmware version'
# atteso: rtw89_8852ce ...: Firmware version 0.27.56.14

# 3. Autosuspend BT disattivato
cat /sys/bus/usb/devices/1-4/power/control   # deve essere "on"

# 4. Se dopo il boot compare ancora 0.27.129.4,
#    significa che il driver lo ha preso dall'initramfs. Rigenerare:
pkexec dracut --force
```

---

## Secondo problema: freeze/riavvio del sistema (NVMe Micron 2550)

### Sintomo

Il sistema si **congela completamente** (schermo nero/bloccato, "come un logout")
e richiede riavvio forzato. Succede a random, con più frequenza:
- quando il PC va in **sospensione** (chiusura coperchio → `s2idle`) e non si
  risveglia più;
- durante **I/O intenso** (riproduzione video YouTube, download pesanti).

Non è legato al fix audio: capita anche senza cuffie BT.

### Diagnosi (come ho capito cosa non andava)

Il sospetto iniziale era il risveglio `s2idle` su APU AMD (bug kernel noto
v7.0→v7.1), quindi sono stati aggiunti `amdgpu.runpm=0` e l'auto-suspend è stato
spento. I freeze però continuavano **anche senza sospensione**. Nei log:

```bash
pkexec dmesg | grep -i 'resetting controller'
# -> nvme nvme0: resetting controller due to persistent internal error
```

E al momento del crash (stesso secondo):

```
nvme nvme0: resetting controller due to persistent internal error
PM: suspend entry (s2idle)        <- freeze, mai "suspend exit"
```

Altri indizi: il boot successivo riporta
`x86/amd: Previous system reset reason [0x08000800]: an uncorrected error caused
a data fabric sync flood event` (l'errore NVMe propaga al data fabric AMD) e
`nvme0n1: I/O Error (sct 0x3 / sc 0x71)`.

Il controller NVMe **Micron 2550** con **APST attivo** invia un "Persistent
Internal Error" (AEN) e va in reset, spesso durante la transizione di
sospensione/risveglio o sotto I/O. Questo congela tutto il sistema.
smartctl può mostrare il disco "sano" (0 errori, 35°C) perché l'errore è
transitorio del controller, non della NAND.

> Riferimenti: `nvme_handle_aer_persistent_error()` in `drivers/nvme/host/core.c`
> (il messaggio viene da un AEN del dispositivo); casi identici documentati su
> Framework 13/16 AMD + s2idle + NVMe.

### Soluzione (karg kernel, reversibili)

Disattivare il risparmio energetico che innesca l'errore:

```bash
# APST NVMe disattivato + power management porte PCIe off
pkexec rpm-ostree kargs \
  --append="nvme_core.default_ps_max_latency_us=0" \
  --append="pcie_port_pm=off" \
  --append="amdgpu.runpm=0"
systemctl reboot
```

Verifica dopo il reboot:

```bash
cat /sys/module/nvme_core/parameters/default_ps_max_latency_us  # -> 0
tr ' ' '\n' < /proc/cmdline | grep -E 'nvme_core|pcie_port_pm|amdgpu'
pkexec dmesg | grep -iE 'amdgpu.*runtime pm is manually disabled'
```

### Misure complementari

- **Auto-suspend da idle OFF** (il PC non si sospende da solo dopo 15 minuti,
  che era il trigger "a sorpresa" più frequente):

  ```bash
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
  ```

- Aggiornare il **firmware NVMe** se disponibile (via BIOS/vendor): è la fix
  definitiva per i problemi APST/AEN della Micron 2550.

### Come annullare

```bash
pkexec rpm-ostree kargs \
  --delete="nvme_core.default_ps_max_latency_us=0" \
  --delete="pcie_port_pm=off" \
  --delete="amdgpu.runpm=0"
systemctl reboot
```

---

## Come annullare (per un kernel futuro che fixa la regressione)

Quando un aggiornamento del kernel/linux-firmware introduce un firmware stabile,
togli il workaround:

```bash
rpm-ostree kargs --delete="firmware_class.path=/etc/firmware"
rm -rf /etc/firmware/rtw89
systemctl reboot
```

---

## Importante: dopo ogni aggiornamento kernel

`kernel`/`linux-firmware` possono **ripristinare** i file problematici originali.
Il workaround via `/etc/firmware` + karg è resistente agli update, ma un nuovo
firmware "stabile" potrebbe rendere il workaround inutile: riapplica la verifica
`pkexec dmesg | grep 'Firmware version'` dopo ogni update per confermare che la
versione sia ancora la stabile voluta.