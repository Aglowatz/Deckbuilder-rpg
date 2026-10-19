# Playtest feedback log

One row per piece of feedback (a playtester's F8 report, a message, a call note). Add F8 reports with the tool, which fills in what the
report knows and guesses the rest for you to correct:

```
node tools/feedback_row.js "<path to the report folder>" --reporter=Sam [--category=bug] [--severity=high] [--dry]
```

The report folder is the one the game opens after **Report a Problem** (F8 or Pause > Report a Problem); testers zip and send it.
They live in `%APPDATA%\Deckbuilder-RPG\feedback\` (the project uses a custom user folder, for the editor and exported builds alike).
The tool reads `report.json` (version, area, quest and step, rating, notes), guesses the category from the notes and appends a row
with the next ID. Running it twice on the same folder does nothing (the folder name is kept in the Report column).

Columns:

- **Category**: `bug` (something broke or behaved wrongly), `confusion` (the player did not know what to do or what happened),
  `balance` (too hard / too easy / too slow), `praise` (keep this).
- **Severity**: `blocker` (cannot continue, crash, lost progress), `high` (wrong behaviour or a wall most players hit), `medium`
  (noticeable, has a workaround), `low` (polish). Praise is always `-`.
- **Status**: `new` -> `triaged` -> `fixed <version or commit>` / `wontfix (why)` / `duplicate F-NNN`.

| ID | Date | Reporter | Version | Area / quest | Category | Severity | Status | Summary | Report |
|---|---|---|---|---|---|---|---|---|---|
