---
name: skill-creator
description: Use when the user asks to save, document, or transform a resolved task or problem-solving session into a reusable opencode skill ("crea una skill", "salva il processo", "crea skill-creator"). Captures the general/generic process, the reasoning, the steps followed, and how the resolution was carried out, then generalizes it into a SKILL.md that can be reused on future similar tasks.
---

# Skill Creator

Trasforma un problema risolto (o una sessione di lavoro conclusa) in una skill
opencode riutilizzabile. Obiettivo: salvare il **processo generale e generico**
— il ragionamento, i passi seguiti, le verifiche fatte e il come è stata svolta
la risoluzione — e non la singola soluzione specifica.

## Quando usarla

Attivare quando l'utente chiede, esplicitamente o implicitamente, di:
- salvare/documentare il processo di risoluzione di un problema appena concluso;
- creare una nuova skill (anche "skill-creator", "crea una skill", ecc.);
- generalizzare un task specifico in una procedura riutilizzabile.

Non usarla per risolvere il problema in sé: prima completare il task, poi
salvare il processo.

## Flusso di lavoro

1. **Ricostruire il processo reale svolto** (non una procedura ideale):
   - dal contesto della sessione, estrarre il ragionamento iniziale e le ipotesi;
   - elencare i passi realmente seguiti, in ordine;
   - annotare gli errori/ostacoli incontrati e come sono stati superati;
   - annotare i comandi, le tool e le verifiche effettivamente usati.

2. **Generalizzare**: sostituire i dettagli specifici del task con la forma
   generica:
   - nomi di file/progetti/percorsi → segnaposto generici (`<project>`, `target`);
   - valori concreti → esempi o parametri;
   - i passi del task → fase di un processo riutilizzabile.

3. **Verificare la riusabilità**: chiedersi "se domani arrivasse un task simile,
   questi passi funzionerebbero da soli?" Se un passo dipende da un dettaglio
   del task originale, astrarlo o renderlo condizionale.

4. **Scrivere la SKILL.md** (vedi sotto).

5. **Confermare con l'utente**: mostrare un riepilogo del processo catturato e
   della posizione del file prima di dichiarare completato.

## Dove salvare la skill

| Scope    | Percorso                                                  |
| -------- | --------------------------------------------------------- |
| Progetto | `.opencode/skills/<nome>/SKILL.md`                        |
| Globale  | `~/.config/opencode/skills/<nome>/SKILL.md`               |

Preferire il progetto se il processo è specifico del progetto; altrimenti la
skill globale. Se il percorso non esiste, crearlo (`mkdir -p`).

## Struttura della SKILL.md da generare

```markdown
---
name: <nome-skill>
description: Una frase su COSA fa la skill e QUANDO usarla. Anteporre le parole chiave o i nomi di file che l'utente potrebbe dire. Terza persona ("Use when...", non "Io aiuto...").
---

# <Nome Skill>

(introduzione: a cosa serve, quando attivarla)

## Quando usarla
(trigger espliciti e limiti, con "Use ONLY when..." se va tenuta silenziosa su argomenti vicini)

## Passi
1. ...
2. ...

## Verifiche
- comando/check da eseguire per confermare il risultato

## Errori noti / Ostacoli
- problema incontrato → come risolverlo

## Esempio (opzionale)
(esempio breve, generico, senza dettagli del task originale)
```

Requisiti frontmatter:
- `name`: obbligatorio, minuscolo, separato da trattini, max 64 caratteri, uguale al nome della cartella.
- `description`: di fatto obbligatoria — senza, la skill viene filtrata e mai esposta al modello.

## Regole di qualità

- Salvare il **come** (ragionamento, comandi, errori, verifiche), non solo il **cosa**.
- La skill deve essere **generica e riusabile**: nulla di hard-coded dal task originale.
- Non aggiungere commenti inutili: la skill è già documentazione, va scritta pulita.
- Se una fase richiede tool specifici, nominarli esplicitamente.
- Terminare sempre ricordando all'utente di **riavviare opencode** perché la nuova
  skill venga caricata (la config non viene ricaricata a caldo).

## Attenzione

- Non inventare passi mai eseguiti: la skill deve riflettere il processo reale.
- Se il processo catturato non è generalizzabile (troppo specifico o frammentato),
  dirlo all'utente e proporre di tenerla come nota/checklist locale invece che skill.
