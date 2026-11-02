---
name: lvm-vdo-dev-storage
description: Use when creating a development storage volume with LVM-VDO (dedup/compression) and XFS, wiring dev caches (Maven, Gradle, npm, pnpm) onto it, or making such a mount persist on immutable/atomic Linux (Bluefin, Bazzite, Fedora Atomic) with systemd instead of fstab. Covers loopback fallback when no second disk exists, sizing rules, TRIM/fstrim, swap sizing (zram + btrfs swapfile), SELinux var_lib_t exec failures and pkexec-only privilege handling. Trigger keywords: lvm-vdo, vdo, lvcreate --type vdo, vdoformat, dm_vdo, loopback, XFS, cache dev, disco secondario, swap, zram, fstrim, var/mnt/projects, systemd service mount.
---

# Volume di sviluppo LVM-VDO + XFS

Procedura per creare uno storage separato per cache di sviluppo e workspace,
con LVM-VDO (compressione + deduplicazione) e XFS, e renderlo persistente su
un sistema immutabile. Il processo è pensato per essere eseguito **in fasi
sequenziali con conferma dell'utente prima di ogni passo distruttivo**.

## Quando usarla

- L'utente chiede un volume LVM-VDO, un "disco di sviluppo", un mount dedicato
  per cache Maven/Gradle/npm/pnpm.
- Si deve spostare `~/.m2`, `~/.gradle`, `~/.npm`, store pnpm su un altro FS.
- Si deve rendere persistente un mount basato su loop device su un sistema
  con `/etc/fstab` gestito da OSTree.
- Include anche la parte swap (zram + swapfile) quando richiesta insieme.

Non usarla per partizionamenti distruttivi di dischi di sistema: in quel caso
fermarsi e chiedere.

## Regole trasversali

1. **Discovery prima di tutto, sola lettura.** Nessun `pvcreate`/`mkfs` finché
   l'utente non ha confermato dispositivo, dimensioni e cosa verrà perso.
2. **Privilegi con `pkexec`, mai `sudo`.** Le redirezioni (`>`, `>>`) girano
   come utente: usare `pkexec tee` o `pkexec bash -c '...'` per raggruppare più
   comandi in una sola autorizzazione.
3. **Identificare i dischi con `/dev/disk/by-id/...`**, mai `/dev/sdX`.
4. **Fermarsi al primo errore** e proporre rimedio o rollback prima di
   proseguire. Non riavviare mai senza consenso esplicito.
5. Mostrare il comando prima di eseguirlo e riportare un output sintetico.

## Fase 0 — Discovery

```bash
rpm-ostree status
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL,SERIAL,TRAN
lsblk -a -d          # rileva dischi non montati/vergini
modinfo dm_vdo       # supporto kernel
command -v vdoformat; command -v lvm
lvm segtypes | grep -i vdo
systemctl is-enabled fstrim.timer
findmnt <mountpoint> # verifica che il target non sia già montato
```

Verificare anche il contesto utente/shell e lo stato delle cache:

```bash
id; echo "$SHELL"
ls -ld ~/.m2 ~/.gradle ~/.npm ~/.npmrc ~/.local/share/pnpm
du -sh ~/.m2 ~/.gradle ~/.npm 2>/dev/null
command -v npm pnpm mvn gradle
```

**Punto decisionale 1 — esiste un disco secondario?**

- Sì, libero e non montato → percorso A (disco reale, persistente).
- No, e il disco unico è interamente partizionato dal sistema → percorso B
  (file loopback). **Non partizionare né ridimensionare il disco di sistema**
  a sistema avviato: proporre il loopback come alternativa temporanea e
  spiegarne i limiti (stesso disco fisico, nessuna indipendenza, TRIM parziale).

**Punto decisionale 2 — `vdoformat` presente?**

Su Bluefin il pacchetto `vdo` di norma non è installato. Prima di installare:

```bash
rpm-ostree install --dry-run vdo   # verifica risoluzione e transazioni pendenti
```

Se risponde `System transaction in progress`, c'è un deployment staged: far
applicare l'aggiornamento con un reboot (preferibile) oppure scartarlo con
`rpm-ostree cleanup -p`. Poi:

```bash
pkexec rpm-ostree install -y vdo     # layering: richiede reboot
```

Dopo il reboot verificare `vdoformat --version`.

## Fase 1 — Preparazione del device

### Percorso A — disco reale

```bash
pkexec pvcreate /dev/disk/by-id/<DISCO>
pkexec vgcreate <VG> /dev/disk/by-id/<DISCO>
```

### Percorso B — file loopback

```bash
pkexec bash -c 'fallocate -l <SIZE>G /var/lib/<name>.img && chmod 600 /var/lib/<name>.img'
pkexec losetup --find --show --sector-size 4096 /var/lib/<name>.img   # -> /dev/loopN
losetup -l                                                            # verifica LOG-SEC 4096
```

Note:

- Preferire `fallocate` a `dd` (veloce, preallocato).
- `--sector-size 4096` allinea il loop ai settori 4K attesi da VDO/XFS.
- Il file resta preallocato: il TRIM libera blocchi dentro VDO, ma non
  restituisce spazio al filesystem sottostante.

## Fase 2 — Volume VDO

Dimensionamento:

- **fisica** = ~90% dello spazio del VG (lasciare ~10% di slack: un pool pieno
  produce errori "out of space" logici);
- **virtuale** = 3x la fisica;
- comunicare le dimensioni all'utente prima di eseguire.

```bash
pkexec lvcreate --type vdo -n <LV> -L <FISICA>G -V <VIRTUALE>G \
  --compression y --deduplication y -y <VG>
pkexec lvs -a <VG>
```

Note:

- `-y` evita i prompt interattivi sotto `pkexec`.
- `--indexmem` **non** è un'opzione LVM: per VDO si usano `--vdosettings` o
  `vdoformat --uds-memory-size`.
- `Data%` iniziale del pool (~4-5%) è overhead di formattazione, non dati.

## Fase 3 — Filesystem, mount, struttura

```bash
pkexec mkfs.xfs -K /dev/<VG>/<LV>            # -K: nessun discard in formattazione
pkexec bash -c 'mkdir -p <MOUNT> && mount /dev/<VG>/<LV> <MOUNT>'
pkexec chown -R "$USER:$USER" <MOUNT>          # senza chown il mount resta di root
mkdir -p <MOUNT>/workspace <MOUNT>/cache/{m2,gradle,npm,pnpm}
pkexec systemctl enable --now fstrim.timer     # con VDO è essenziale
pkexec fstrim -v <MOUNT>                       # verifica che il TRIM passi
```

Il `chown` è indispensabile: senza, i test di scrittura utente falliscono e le
cache non sono scrivibili.

## Fase 4 — Persistenza del mount

**Non mettere in fstab una riga per un mapper VDO basato su loop**: al boot il
loop non esiste e il mount fallisce. Usare un service oneshot con script
idempotenti (start/stop).

Struttura:

```
/etc/systemd/system/<name>.service
/var/lib/<name>/<name>-attach.sh
/var/lib/<name>/<name>-detach.sh
```

Unit:

```ini
[Unit]
Description=Mount LVM-VDO volume from loopback image
After=var.mount
Requires=var.mount
Before=multi-user.target
ConditionPathExists=/var/lib/<name>.img

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash /var/lib/<name>/<name>-attach.sh
ExecStop=/bin/bash /var/lib/<name>/<name>-detach.sh
TimeoutStartSec=120
TimeoutStopSec=120

[Install]
WantedBy=multi-user.target
```

Logica attach (idempotente):

1. verificare che l'immagine esista;
2. riusare il loop esistente (`losetup -j`) o attaccarlo con `--sector-size 4096`;
3. `lvmdevices --adddev "$LOOP"` (o fallback `vgchange -ay --config 'devices/use_devicesfile=0'`);
4. `vgchange -ay <VG>`;
5. montare solo se `mountpoint -q` è falso.

Logica detach: `umount` se montato → `vgchange -an` → `losetup -d`.

Attivazione e test:

```bash
pkexec bash -c 'systemctl daemon-reload && systemctl enable <name>.service'
pkexec systemctl start <name>.service
pkexec systemctl stop <name>.service     # verifica stop
pkexec systemctl start <name>.service     # verifica start
systemctl status <name>.service
```

Se in modalità temporanea (solo sessione), saltare questa fase e documentare il
comando di riattivazione manuale.

## Fase 5 — Cache di sviluppo

Spostare le cache esistenti **prima** di reindirizzare, per evitare duplicati.

- **Maven**: `~/.m2/settings.xml` con
  `<localRepository><MOUNT>/cache/m2</localRepository>`.
- **Gradle**: `export GRADLE_USER_HOME=<MOUNT>/cache/gradle` nel file di
  profilo attivo (verificare `echo $SHELL`) **e** in `~/.profile`.
- **npm**: `~/.npmrc` con `cache=<MOUNT>/cache/npm`.
- **pnpm**: `~/.npmrc` con `store-dir=<MOUNT>/cache/pnpm`.
  Attenzione: `~/.local/share/pnpm` è `PNPM_HOME`, non lo store: non symlinkarlo.

Fare un backup dei file di profilo prima di modificarli. Se i tool non sono
installati sull'host, le verifiche runtime non sono eseguibili: dichiararlo e
ricordare che dentro container/toolbox vanno riesportate le variabili.

## Fase 6 — Swap (se richiesta)

- Swap su VDO **no**: volume temporaneo e dedup/compressione inadatti.
- `zram-size` = 16G con ~16G di RAM **fallisce** con `ENOMEM` su
  `/sys/block/zram0/disksize`: ripristinare subito la config precedente e
  proporre l'alternativa.
- Alternativa: zram 8 GiB + swapfile 8 GiB su btrfs (totale 16 GiB).

```bash
pkexec btrfs filesystem mkswapfile --size 8G /var/swapfile
printf '/var/swapfile none swap defaults,nofail 0 0\n' | pkexec tee -a /etc/fstab
```

La swap unit generata da fstab non dipende da `/var`: aggiungere
`/etc/systemd/system/var-swapfile.swap.d/after-var.conf` con
`Requires=var.mount` e `After=var.mount`, poi `daemon-reload` e `start`.

## Verifiche

```bash
findmnt <MOUNT>; df -h <MOUNT>
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
pkexec lvs -o name,size,data_percent,vdo_saving_percent <VG>
touch <MOUNT>/workspace/.test && rm <MOUNT>/workspace/.test && echo OK
systemctl is-enabled <name>.service; systemctl is-active <name>.service
swapon --show; free -h
```

Dopo un reboot reale: `journalctl -u <name>.service -b` deve mostrare attach +
mount, e il test di scrittura deve passare.

## Errori noti / Ostacoli

| Sintomo | Causa | Rimedio |
|---|---|---|
| `System transaction in progress` da `rpm-ostree install` | deployment staged | reboot per applicarlo, o `rpm-ostree cleanup -p` |
| `lvcreate --type vdo` chiede conferme e fallisce sotto pkexec | prompt interattivo | aggiungere `-y` |
| `Cannot allocate memory` su `disksize` di zram | zram ≥ RAM | usare min(RAM, 8G) + swapfile su disco |
| `203/EXEC` / `Permission denied` nell'ExecStart | script in `/var/lib` con contesto SELinux `var_lib_t` | invocare con `/bin/bash /percorso/script` (o `chcon` dedicato) |
| mount assente dopo reboot con riga fstab su loop | il loop non esiste al boot | service oneshot con attach idempotente |
| swapfile non parte al boot | manca dipendenza da `/var` | drop-in `Requires=var.mount`, `After=var.mount` |
| `blockdev --getss /dev/loopN` permission denied da utente | richiede root | usare `losetup -l` (colonna LOG-SEC) |
| `lvs`/`vgs` da utente: driver device-mapper non raggiungibile | manca root | eseguire con `pkexec` |

## Rollback

```bash
pkexec systemctl disable --now <name>.service
pkexec losetup --find --show --sector-size 4096 /var/lib/<name>.img
pkexec vgremove -y <VG>
pkexec pvremove /dev/loopN
pkexec lvmdevices --deldev /dev/loopN 2>/dev/null || true
pkexec losetup -d /dev/loopN
pkexec rm -f /var/lib/<name>.img
pkexec rm -rf /var/lib/<name>
pkexec rm -f /etc/systemd/system/<name>.service
pkexec systemctl daemon-reload
```

Per la swap: `systemctl stop var-swapfile.swap`, `swapoff`, rimuovere la riga
fstab e il drop-in. Tenere sempre un backup di fstab prima di modificarlo
(`/etc/fstab.bak.$(date +%F-%H%M)`).
