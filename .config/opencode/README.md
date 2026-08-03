# OpenCode — config

Qui c'è la configurazione globale di OpenCode, sincronizzata dai DotFiles.

La cartella sul disco (dove OpenCode va a leggere) è `~/.config/opencode/` in Linux/macOS e WSL (Windows consigliato tramite WSL). I **symlink** creati da `autorun.sh → links()` puntano i file qui dentro verso la cartella reale.

## File tracciati (questi stanno in git)

| File / cartella            | Ruolo                                              |
| -------------------------- | -------------------------------------------------- |
| `opencode.jsonc`           | Config principale (schema `opencode.ai/config.json`) |
| `.gitignore`               | Esclude `node_modules`, `package*.json`, `bun.lock` da git |
| `skills/`                  | Skill custom (agent "skill")                       |
| `skills/<nome>/SKILL.md`   | Definizione di ogni singola skill                  |

## File NON tracciati (restano solo in locale)

Quelli esclusi da `.gitignore` e quindi presenti solo nella copia locale (non nel repo):

| File                      | Ruolo                                            |
| ------------------------- | ------------------------------------------------ |
| `node_modules/`           | Dipendenze dei plugin                            |
| `package.json`            | Plugin definiti via npm                          |
| `package-lock.json`       | Lock del resolvo plugin                          |

Non vanno sincronizzati: sono specifici della macchina e reinstallati tramite `npm install`.

## Dove vanno i file per piattaforma

### Linux / macOS / WSL

| Cosa                       | Path                                                    |
| -------------------------- | ------------------------------------------------------ |
| Config globale             | `~/.config/opencode/opencode.json` (o `.jsonc`)        |
| Config TUI                 | `~/.config/opencode/tui.json`                          |
| Skill                      | `~/.config/opencode/skills/<nome>/SKILL.md`            |
| Agents                     | `~/.config/opencode/agents/`                           |
| Commands                   | `~/.config/opencode/commands/`                         |
| Plugins                    | `~/.config/opencode/plugins/`                          |
| Temi / keybind / modi      | `~/.config/opencode/{themes,keybinds,modes}/`          |
| Dati di sessione (stato)   | `~/.local/share/opencode/`                             |
| **Managed (admin, Linux)** | `/etc/opencode/`                                       |

Qui sopra Linux/macOS/WSL è equivalente. Su macOS il managed system invece è `/Library/Application Support/opencode/`.

### Windows (nativo, senza WSL)

Su Windows nativo la cartella utente equivalente è contenuta in `%USERPROFILE%\.config\opencode\` (config, skills, agents, commands, plugins). Il resto si allinea ai nomi uguali visti sopra.

| Cosa                    | Path                                              |
| ----------------------- | ------------------------------------------------- |
| Config globale          | `%USERPROFILE%\.config\opencode\opencode.jsonc`   |
| TUI                     | `%USERPROFILE%\.config\opencode\tui.json`         |
| Skill                   | `%USERPROFILE%\.config\opencode\skills\<nome>\SKILL.md` |
| Agents / Commands       | `%USERPROFILE%\.config\opencode\{agents,commands}\` |
| Plugins                 | `%USERPROFILE%\.config\opencode\plugins\`         |
| Dati sessione           | `%USERPROFILE%\.local\share\opencode\` (se con WSL, dentro WSL: `~/.local/share/opencode/`) |
| **Managed** (admin+WIN) | `%ProgramData%\opencode`                            |

### Windows tramite WSL (consigliata)

Con WSL i path diventano quelli Linux, nel filesystem WSL:

- Config: `~/.config/opencode/opencode.jsonc` (dentro la distro WSL)
- Sessione/stato: `~/.local/share/opencode/` (dentro la distro WSL)

I tuoi file Windows del progetto si raggiungono da `/mnt/c/...`, ma per la config OpenCode conviene usare il filesystem WSL (più veloce).

## Setup

Per sincronizzare tutto sul sistema, esegui (dai DotFiles):

```bash
# assicurati che la cartella reale esista
mkdir -p ~/.config/opencode
# collegare i file tracciati
ln -sf ~/git/DotFiles/.config/opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
ln -sf ~/git/DotFiles/.config/opencode/.gitignore ~/.config/opencode/.gitignore
ln -sf ~/git/DotFiles/.config/opencode/skills ~/.config/opencode/skills
# poi, una sola volta, reinstalla i plugin locali
cd ~/.config/opencode && npm install
```

## Riferimenti

- Config schema: <https://opencode.ai/docs/config/>
- Skill: <https://opencode.ai/docs/skills/>
- Windows/WSL: <https://opencode.ai/docs/windows-wsl/>