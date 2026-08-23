---
name: rpi-flash-fix
description: Fix per flash Raspberry Pi con Raspberry Pi Imager quando le impostazioni di personalizzazione (wifi, hostname, ssh, utente) non vengono applicate: file cloud-init su bootfs, blocchi rfkill e NetworkManager.state, diagnostica con diag.txt. Use when the user mentions flashing a Raspberry Pi SD card/USB stick, bootfs/rootfs partitions, imager settings not applying, Pi not appearing on network/nmap.
---

# Fix flash Raspberry Pi: impostazioni Imager non applicate / Pi invisibile in rete

Procedura validata sul campo (agosto 2026, Raspberry Pi OS trixie 2026-06-18, Pi 4, Imager flatpak 1.9.6).

## Contesto

Le immagini recenti di Raspberry Pi OS sono **cloud-init based**: le impostazioni
(hostname, utente, ssh, timezone, tastiera) stanno in `user-data` nel bootfs,
il WiFi in `network-config`. L'Imager a volte NON compila questi file (restano i template vuoti)
e/o lascia la radio WiFi bloccata da due interruttori persistenti.

## 1. Identificare la chiavetta e i dati salvati nell'Imager

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL        # cercare bootfs (vfat ~512M) + rootfs (ext4)
cat ~/.var/app/org.raspberrypi.rpi-imager/config/'Raspberry Pi'/Imager.conf
# sezione [imagecustomization]: hostname, sshUserName, sshUserPassword (hash $5$),
# timezone, keyboardLayout, wifiSSID/Password/Country, wifiSSIDHidden
```

Montare con udisks (no root): `udisksctl mount -b /dev/sdX1` (bootfs) e `/dev/sdX2` (rootfs).
I punti di mount sono `/run/media/<utente>/bootfs` e `/run/media/<utente>/rootfs`.
Molti file sono root:root 600 → serve `sudo`/`pkexec` per leggerli/modificarli.

## 2. Scrivere le impostazioni nei file cloud-init (bootfs)

`user-data` (attenzione: YAML sensibile agli spazi):

```yaml
#cloud-config
hostname: <host>
timezone: Europe/Rome
keyboard:
  model: pc105
  layout: us
ssh_pwauth: true
users:
  - name: <utente>
    gecos: Raspberry Pi user
    groups: [adm, dialout, cdrom, audio, users, sudo, video, games, plugdev, input, netdev, render, lpadmin]
    shell: /bin/bash
    lock_passwd: false
    passwd: '<hash dall'Imager.conf, tipo $5$...>'
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
```

`network-config`:

```yaml
network:
  version: 2
  ethernets:
    eth0: {dhcp4: true, optional: true}
  wifis:
    wlan0:
      dhcp4: true
      optional: true
      access-points:
        "<SSID>":
          hidden: true          # solo se rete nascosta
          password: "<password>"
```

**Importante**: incrementare `instance_id` in `meta-data` (es. `rpios-image-nome1`)
per forzare cloud-init a rieseguire tutto anche su schede già avviate.
Validare gli YAML con python+pyyaml prima di smontare.

## 3. I DUE blocchi WiFi persistenti (causa radice del "non appare in rete")

1. `/var/lib/systemd/rfkill/*` (su rootfs): stato soft-block persistito, ripristinato ad ogni avvio.
   Fix: `rm -rf .../var/lib/systemd/rfkill/*`
2. `/var/lib/NetworkManager/NetworkManager.state`: contiene `WirelessEnabled=false`,
   NetworkManager ri-blocca la radio DOPO qualsiasi sblocco esterno.
   Fix: cancellare il file.

Servizio di protezione permanente (rootfs) `/etc/systemd/system/unblock-wifi.service`
— DEVE girare DOPO NetworkManager, altrimenti NM ri-blocca:

```ini
[Unit]
Description=Ensure Wi-Fi radio enabled (rfkill + NetworkManager)
Wants=NetworkManager.service
After=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c "/usr/sbin/rfkill unblock wifi && /usr/bin/nmcli radio wifi on"

[Install]
WantedBy=multi-user.target
```

Più symlink: `ln -sf ../unblock-wifi.service .../etc/systemd/system/multi-user.target.wants/`

Extra utili già applicati: `cfg80211.ieee80211_regdom=IT` in cmdline.txt,
`country_code=IT` a fine config.txt, profilo nativo
`/etc/NetworkManager/system-connections/<nome>.nmconnection` (600, root:root)
con ssid/psk/hidden/autoconnect.

## 4. Diagnostica senza rete: netdiag.service

Se il Pi non è raggiungibile, installare (via root) uno script che scarichi lo
stato rete su **diag.txt nel bootfs** (partizione FAT, leggibile da qualunque PC):
rfkill list, ip -br addr, iw dev/reg, nmcli general/device/wifi list --rescan yes,
connessioni, e journalctl filtrato (brcmfmac|cfg80211|wlan0|wpa_supplicant|NetworkManager|rfkill|dhcp).
Unit oneshot After=multi-user.target con sleep ~45 all'inizio, WantedBy=multi-user.target.

Lettura del report (a volte esce come binario per byte null):
```python
open('diag.txt','rb').read().replace(b'\x00',b'').decode('utf-8','replace')
```

Interpretazione:
- `diag.txt` non esiste dopo il boot → il Pi non ha mai avviato (alimentazione/contatti), non è rete
- `Soft blocked: yes` + "disabled by state file" → i blocchi del punto 3
- "unblock set for type wifi" presente ma NM ri-blocca → manca il fix NetworkManager.state
- Radio attiva ma scan vuoto → problema regdom/canale o SSID errato
- Associazione fallita con reason → verificare password/canale >11

## 5. Verifica finale

```bash
nmap -p 22 --open -v 192.168.1.0/24   # o lista client del router
ssh mark@raspberry.local               # o mark@<IP>
```

Smontare SEMPRE con `sync && udisksctl unmount -b /dev/sdX1 && udisksctl unmount -b /dev/sdX2`.

Note ambiente: sudo richiede terminale → usare `pkexec` (apre prompt polkit grafico);
i percorsi dentro pkexec devono essere assoluti col punto di mount completo.
