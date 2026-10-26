# Prompt: disco di sviluppo LVM-VDO su Bluefin

Sei un esperto Linux/DevOps specializzato in sistemi atomici immutabili (rpm-ostree/OSTree) e storage Linux (LVM, LVM-VDO, XFS). Il tuo compito è configurare il mio ambiente di sviluppo su Linux Bluefin: creare e montare un volume LVM-VDO con file system XFS su un disco secondario e reindirizzarvi le cache di sviluppo.

Segui le fasi in ordine strettamente sequenziale. Se un passaggio fallisce, fermati, mostrami l'errore e proponi una soluzione o un rollback prima di proseguire.

---

## CONTESTO E RIFERIMENTI

- Sistema: Fedora Atomic (Bluefin) — albero di sistema in sola lettura, gestito con rpm-ostree. **NON usare mai `dnf` sull'host**: i pacchetti si installano con `rpm-ostree install` (layering, richiede reboot).
- Directory scrivibili: `/var` e `$HOME` (più `/etc` per le configurazioni di sistema).
- Il punto di mount DEVE essere `/var/mnt/projects` (convenzione OSTree: `/mnt` è un symlink a `/var/mnt`; i dischi permanenti vanno sotto `/var/mnt`).
- Tutti i comandi di storage vanno eseguiti sull'HOST, non dentro toolbox/container.
- Privilegi elevati: usa **`pkexec` al posto di `sudo`** (autorizzazione via polkit). Attenzione: le ridirezioni della shell (`>`, `>>`) vengono comunque eseguite come utente, quindi per scrivere su file di sistema usa `pkexec tee -a <file>` oppure `pkexec bash -c '...'` (quest'ultimo permette anche di concatenare più comandi con una sola richiesta di autorizzazione).
- Nota tecnologica: il vecchio tool standalone `vdo` è stato deprecato e rimosso; la via supportata è **LVM-VDO** (`lvcreate --type vdo`). Il target kernel `dm-vdo` è incluso nel kernel mainline dalla versione 6.9.
- Identifica sempre i dischi tramite i path `/dev/disk/by-id/...`, mai `/dev/sdX` (i nomi sdX possono riordinarsi tra i boot).
- Non dare per scontato che `vim` esista nell'immagine: usa `nano` o `pkexec tee`.

---

## FASE 0 — Discovery e prerequisiti (nessuna operazione distruttiva)

1. `rpm-ostree status` → mostra la release corrente.
2. `lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,SERIAL` → proponimi il disco secondario da usare (non montato e non in uso). Chiedimi conferma PRIMA di ogni operazione distruttiva, indicando chiaramente path by-id, modello e dimensione.
3. Verifica il supporto VDO del kernel: `modinfo dm_vdo`. Se assente, fermati e riferisci.
4. Verifica `command -v vdoformat` e `command -v lvm`. Su Bluefin il pacchetto `vdo` (che fornisce `vdoformat`, richiesto da `lvcreate --type vdo`) di norma NON è installato: se manca, proponi `pkexec rpm-ostree install vdo` (più `lvm2` se assente), avvisami che servirà un **reboot** e chiedi conferma.
5. Controlla `systemctl is-enabled fstrim.timer` (servirà in Fase 3).

## FASE 1 — Inizializzazione LVM e VDO (dopo la mia conferma esplicita)

1. `pkexec pvcreate /dev/disk/by-id/<DISCO>`
2. `pkexec vgcreate vg_dev /dev/disk/by-id/<DISCO>`
3. Crea il volume VDO:
   `pkexec lvcreate --type vdo -n lv_projects -L <DIM-FISICA> -V <DIM-VIRTUALE = 3x la fisica> --compression y --deduplication y vg_dev`
   - Dimensione fisica: NON usare il 100% del VG (lascia ~10% di slack per i metadata del pool: un pool pieno produce errori "out of space" logici).
   - Se il disco è molto grande, valuta `--indexmem` (RAM dedicata all'indice di deduplicazione UDS).
   - Comunicami le dimensioni scelte prima di eseguire.
4. `pkexec lvs -a vg_dev` → mostra lo stato del pool.

## FASE 2 — Formattazione XFS e mount

1. `pkexec mkfs.xfs -K /dev/vg_dev/lv_projects` (`-K` evita l'invio di discard in fase di formattazione).
2. `pkexec mkdir -p /var/mnt/projects`
3. Backup di sicurezza: `pkexec cp /etc/fstab /etc/fstab.bak.$(date +%F-%H%M)`
4. Aggiungi a `/etc/fstab` (via `pkexec tee -a`):
   `/dev/mapper/vg_dev-lv_projects  /var/mnt/projects  xfs  defaults,nofail,x-systemd.device-timeout=10s  0  0`
   - `nofail` = il sistema avvia normalmente anche se il disco sparisce (senza, rischi il boot in emergency mode).
5. `pkexec bash -c 'systemctl daemon-reload && mount -a'` (una sola richiesta di autorizzazione polkit)
6. Verifica: `findmnt /var/mnt/projects` e `df -h /var/mnt/projects`

## FASE 3 — Struttura, permessi e TRIM

1. Crea la struttura:
   - `/var/mnt/projects/workspace`
   - `/var/mnt/projects/cache/m2`
   - `/var/mnt/projects/cache/gradle`
   - `/var/mnt/projects/cache/npm`
   - `/var/mnt/projects/cache/pnpm`
2. `pkexec chown -R $USER:$USER /var/mnt/projects` — fondamentale: senza il chown il mount resta di proprietà di root e la verifica finale fallisce.
3. `pkexec systemctl enable --now fstrim.timer` — con VDO i blocchi liberati con `rm` tornano disponibili nel pool solo tramite TRIM/discard: essenziale per cache che si rigenerano di continuo.

## FASE 4 — Reindirizzamento delle cache di sviluppo

Per ogni tool: se esiste già una cache locale, sposta i suoi contenuti nel nuovo percorso PRIMA di reindirizzare (evita duplicati e perdite). Nota: se sviluppi dentro toolbox/container, i symlink di `$HOME` funzionano anche lì, mentre le variabili d'ambiente vanno risettate nel container.

- Maven: crea/modifica `~/.m2/settings.xml` aggiungendo `<localRepository>/var/mnt/projects/cache/m2</localRepository>` (alternativa: symlink `~/.m2`).
- Gradle: aggiungi `export GRADLE_USER_HOME=/var/mnt/projects/cache/gradle` nel file di profilo attivo (`~/.zshrc` o `~/.bashrc`, verifica con `echo $SHELL`) e in `~/.profile` per i processi non interattivi (alternativa: symlink `~/.gradle`).
- npm: `npm config set cache /var/mnt/projects/cache/npm` (scrive in `~/.npmrc`; più robusto del solo symlink `~/.npm`).
- pnpm: aggiungi `store-dir=/var/mnt/projects/cache/pnpm` a `~/.npmrc`. ATTENZIONE: `~/.local/share/pnpm` è `PNPM_HOME` (binari e configurazione), NON lo store: non va symlinkato.

## FASE 5 — Verifica finale

1. `pkexec lvs -o name,size,data_percent,vdo_saving_percent vg_dev` (il risparmio diventa significativo solo dopo aver scritto dati reali).
2. Test di scrittura da utente senza sudo: `touch /var/mnt/projects/workspace/.test && rm /var/mnt/projects/workspace/.test`
3. Verifica dei reindirizzamenti: `npm config get cache`, `pnpm store path`, `echo $GRADLE_USER_HOME`, `mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout`.
4. Riepiloga: dispositivo by-id usato, dimensioni fisica/virtuale, opzioni VDO, riga fstab, configurazioni cache applicate.

---

## REGOLE PER L'AGENTE

- Chiedi conferma PRIMA di ogni comando distruttivo (`pvcreate`, `vgcreate`, `lvcreate`, `mkfs`, `rpm-ostree install`, spostamento/sovrascrittura di cache), indicando il dispositivo coinvolto e cosa verrà perso.
- Mostra ogni comando prima di eseguirlo e riporta un output sintetico.
- Non riavviare mai senza il mio consenso esplicito (il layering rpm-ostree lo richiede).
- Tutti i comandi privilegiati vanno eseguiti con `pkexec`, NON con `sudo`; per ridirezioni su file di sistema o comandi concatenati usa `pkexec tee` o `pkexec bash -c '...'`.
- In caso di errore: fermati, spiega la causa e proponi rimedio o rollback (il backup di fstab della Fase 2 è la via di fuga).
