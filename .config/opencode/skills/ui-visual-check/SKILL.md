---
name: ui-visual-check
description: Use ONLY when the user asks to visually check the UI ("controlla come sta venendo", "vedi com'è /login", "verifica il fix visivo"), or after implementing/modifying pages, routes, components or CSS. Do NOT activate for backend/API/database-only changes, CLI or Delphi projects, or non-visual tasks.
---

# Check visivo della UI

Loop: **apri → guarda → diagnostica → fixa → riverifica**. Massimo **5 iterazioni**.

## 0. Prerequisiti (auto-riparazione)

Se i tools `browser_*` (MCP Playwright) sono già disponibili nella sessione, salta questo passo e vai al workflow.

Se NON sono disponibili, ripara i prerequisiti creando/modificando i file interessati, in quest'ordine:

1. **Node/npx**: verifica con `npx --version`. Se manca, fermati e segnala che va installato Node (non è auto-riparabile).
2. **Config MCP in `opencode.json`** (root del progetto; se esiste solo `opencode.jsonc`, opera su quello):
   - Il file non esiste → crealo con la config completa qui sotto.
   - Esiste ma manca `mcp.playwright` → leggilo, fai il merge della chiave `mcp` e riscrivilo preservando tutto il resto (per `.jsonc` conserva i commenti).
   - `--headless` è opzionale (toglilo per vedere il browser dal vivo).
3. **Cartella `screenshots/`** → creala se manca.
4. **`.gitignore`** → se non contiene già `screenshots/`, aggiungi la riga (sono artifact temporanei).

Config MCP di riferimento:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest", "--browser", "chromium", "--headless"],
      "enabled": true
    }
  }
}
```

Dopo aver creato/modificato `opencode.json`: se i tools `browser_*` restano indisponibili nella sessione corrente, avvisa l'utente di riavviare opencode per caricare il MCP e fermati. Richiede comunque Node/npx e un opencode recente (`opencode upgrade`).

## 1. Avvia (o trova) il dev server

Rileva stack e porta dagli indizi del repo; in caso di dubbio chiedi all'utente:

| Indizio | Stack | Avvio | Porta default |
|---|---|---|---|
| `package.json` → `vite` | Vite | `npm run dev` | 5173 |
| `package.json` → `next` | Next.js | `npm run dev` | 3000 |
| `package.json` → `astro` | Astro | `npm run dev` | 4321 |
| `app.py` con `import streamlit` | Streamlit | `.venv/bin/python -m streamlit run app.py --server.headless true` | 8501 |
| `manage.py` | Django | `python manage.py runserver` | 8000 |

Verifica se risponde:

```
curl -s -o /dev/null -w "%{http_code}" http://localhost:<porta>
curl -s -o /dev/null -w "%{http_code}" http://localhost:8501/_stcore/health   # Streamlit
```

Se non risponde, avvia in background con log su file:

```
nohup npm run dev > /tmp/devserver.log 2>&1 &
# oppure, per log nel repo:
# mkdir -p logs && nohup npm run dev > logs/devserver.log 2>&1 &
```

Poll ogni 1s, max 30s — puoi usare `check-server.sh` accanto a questo SKILL.md:

```
bash <skill-dir>/check-server.sh http://localhost:<porta>
bash <skill-dir>/check-server.sh http://localhost:<porta> 30
```

Se dopo 30s non parte: leggi il log, segnala e fermati (mai attese infinite).

> Nota cross-platform: in repo è presente anche `check-server.ps1` (legacy Windows:
> `powershell -File <skill-dir>\check-server.ps1 -Url http://localhost:<porta>`).
> Su Linux usa sempre `check-server.sh`.

## 2. Screenshot

Per ogni rotta richiesta (default: `/`):

- `browser_navigate` → `http://localhost:<porta><rotta>`
- `browser_resize` 1440x900 → `browser_take_screenshot` in `screenshots/<rotta>-desktop.png` (usa fullPage per pagine lunghe)
- `browser_resize` 390x844 → `browser_take_screenshot` in `screenshots/<rotta>-mobile.png`
- Crea `screenshots/` se manca; sanitizza il nome: `/` → `index`, `/dashboard/settings` → `dashboard-settings`

## 3. Diagnostica

- `browser_console_messages`: errori e warning rilevanti (ignora noise di estensioni/tracker).
- `browser_network_requests`: segnala 4xx/5xx.
- `browser_snapshot` (albero di accessibilità) per struttura e testi: costa meno token dello screenshot.
- Screenshot per l'estetica, checklist:
  - overflow orizzontale, elementi tagliati o sovrapposti
  - spaziature/allineamenti incoerenti, gerarchia visiva confusa
  - contrasto insufficiente
  - layout rotto su mobile (375-390px), target touch < 40px
  - immagini/font non caricati, scrollbar indesiderate

## 4. Confronto col design (se presente)

Se esiste un PNG di riferimento in `design/` per la rotta, leggilo e confronta: layout, gerarchia, spaziature, colori. Riporta le differenze significative, non i dettagli al pixel.

## 5. Fix e riverifica

1. Correggi SOLO file dell'app: mai config di build/CI, dipendenze, file generati.
2. Se il progetto ha lint/typecheck configurati, eseguili dopo il fix.
3. Attendi ~2s per l'HMR; per stack senza hot reload riavvia il server.
4. Ri-naviga la rotta e rifai screenshot desktop+mobile.
5. Tieni una lista dei problemi aperti e a ogni iterazione riverifica solo quelli. Se dopo 5 iterazioni un problema persiste, fermati e segnala.

## 6. Report finale

```
Rotte controllate: ...
Problemi trovati e fixati: ...
Problemi rimasti: ...
Screenshot: screenshots/...
```

## Note

- Serve un modello con input immagini (Claude, GPT, Gemini): è lui che "vede" gli screenshot.
- I prerequisiti mancanti (config MCP, `screenshots/`, `.gitignore`) vengono creati automaticamente al passo 0.
- La skill è globale (`~/.config/opencode/skills/ui-visual-check/`): vale per tutti i repo.
- Linux: usa `curl`, `nohup`, path POSIX (`/tmp/devserver.log`, `logs/devserver.log`, `.venv/bin/python`). Assicurati che `check-server.sh` sia eseguibile (`chmod +x check-server.sh`).
