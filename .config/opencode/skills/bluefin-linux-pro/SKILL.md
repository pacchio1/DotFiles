---
name: bluefin-linux-pro
description: Use when working on or administering Bluefin Linux (and derivative uBlue/Universal Blue images, e.g. Bazzite). Follows the immutable/atomic design: Flatpak for desktop apps, Homebrew for CLI tools, no rpm-ostree layering, devcontainers for dev, distrobox/toolbox for ad-hoc shells, ujust for maintenance, bootc/rpm-ostree for updates and rollbacks. Trigger keywords: bluefin, ublue, bazzite, ujust, rpm-ostree, bootc, distrobox, toolbox, flatpak, brew, immutabile, layering.
---

# Esperto di Bluefin

Bluefin è un sistema operativo immutabile e atomico basato su Fedora Silverblue
(immagini Universal Blue). Le regole qui sotto preservano l'immutabilità
dell'immagine di base e sfruttano i flussi di aggiornamento atomici.

## Regole d'oro

1. **Flatpak First**: installa le applicazioni desktop esclusivamente tramite
   Flatpak (Flathub). Preserva l'immutabilità del sistema.
2. **Homebrew per la CLI**: gestisci tool e utility da riga di comando tramite
   Homebrew (`brew`).
3. **Evita il Layering (rpm-ostree)**: mantieni l'immagine di base immutata ed
   evita di installare pacchetti RPM a livello di sistema.
4. **Devcontainers per lo sviluppo**: isola gli ambienti di sviluppo in
   container (`devcontainer.json`) gestiti tramite Git, invece di installare
   dipendenze sull'host.
5. **Distrobox/Toolbox per shell isolate**: per lavori CLI ad-hoc che richiedono
   pacchetti non presenti in brew (compilatori, tool specifici di una distro),
   usa `toolbox` o `distrobox` invece di modificare l'host.

## Gestione degli applicativi non standard

Per applicativi che non seguono i metodi sopra indicati (né Flatpak né brew),
sfrutta l'app **DistroShelf** per runnare un container dedicato.

## Manutenzione del sistema

### ujust

Utilizza i comandi della suite **`ujust`** per la manutenzione, gli aggiornamenti
e le configurazioni del sistema. Elenca i comandi disponibili con `ujust --list`.

### Aggiornamenti

- Prima di ogni aggiornamento verifica lo stato con `rpm-ostree status`
  (o `bootc status` sulle build più recenti).
- Applica gli update **solo** tramite `ujust update` o `rpm-ostree upgrade`.
- **Mai** `dnf` diretto sull'host.

### Rollback come rete di sicurezza

In caso di problemi dopo un aggiornamento, usa `rpm-ostree rollback` (o
seleziona la deployment precedente da GRUB) invece di tentare fix manuali
sull'immagine live.

### Moduli kernel extra (akmods / ublue-os kmods)

Per driver non inclusi nell'immagine base (es. NVIDIA, moduli VPN kernel),
preferisci le immagini Bluefin già pre-costruite con gli akmods necessari
piuttosto che compilare moduli manualmente sull'host.

### Secure Boot

Se si abilitano moduli kernel di terze parti, verifica la compatibilità con
Secure Boot (MOK enrollment) prima di procedere, dato che Bluefin lo supporta
by default.

## Gestione dei privilegi

Preferisci `pkexec` o i flussi basati su PolicyKit per le azioni che richiedono
privilegi amministrativi, rispettando il design atomico. Evita `sudo`. 

## Configurazione utente

### Dotfiles versionati

Gestisci la configurazione utente (shell, editor, git config) come repository
Git (es. chezmoi o semplice bare repo) per renderla riproducibile su
reinstallazioni o altre macchine.

### Systemd user units invece di system units

Per servizi legati al singolo utente (sync, backup personali, agent locali)
preferisci unit systemd `--user` piuttosto che unit di sistema, evitando di
toccare `/etc/systemd/system`.

## Regole di comportamento per l'assistenza

- Suggerisci sempre Flatpak prima, poi brew, poi container (DistroShelf /
  distrobox / toolbox). Mai `dnf install` sull'host.
- Per richieste di sviluppo, proponi un devcontainer (file `devcontainer.json`
  in repo) prima di qualsiasi installazione host.
- Prima di un update, esegui/consiglia il check di stato
  (`rpm-ostree status` / `bootc status`).
- In caso di sistema instabile dopo un aggiornamento, consiglia il rollback
  atomico (GRUB / `rpm-ostree rollback`) come prima mossa.
