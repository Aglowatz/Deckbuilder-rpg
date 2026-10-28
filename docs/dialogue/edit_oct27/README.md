# Dialogue edit, Oct 27

`docs/dialogue/edit_oct27.csv` has every player-facing dialogue line in story order, one row per line. It was made by
`node tools/export_dialogue.js`.

| Column | Meaning |
|---|---|
| ID | Where the line lives (`<file>::<key>::<line index>`, see `tools/dialogue_ids.js`). Don't edit it. |
| Zone/Area | The story chapter, plus the dungeon or "gatekeeper" / "after freeing" where that applies |
| Speaker | Who says it. `(narration)`, `(narration/UI)`, `(battle UI)`, `(Quest Log)` and similar mean nobody speaks it |
| When it's heard | The moment in the game |
| Current line | The line as it is now |
| New line | Leave it empty to keep the line. Type the new line to change it |

## Applying

```
node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv            # dry run: report only
node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --apply    # write the changed rows into the game
node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --revert   # put back every line this CSV changed
node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --revert=ids.txt   # put back only the ids listed (one per line)
```

Only rows where New line is filled in and differs from the game are applied. Each one is checked before it is written:
- tokens (`{town}`, `{villain}`...), `%s`/`%d` and `[expression]` tags must stay the same
- no banned old names
- 240 characters at most (barks: under 90)
- the line must fit the dialogue box (Godot measures it)

Quest Log text and dungeon event screens skip the box check, and can grow by up to a quarter. Fig Sly's black market lines are
marked LOCKED and are never changed. Rows that fail a check are listed in `apply_report.md` and are not applied.

You can edit and apply again as often as you like. `applied_ledger.json` keeps each line's original text, so `--revert` always
goes back to the line as it was before this pass. `export_snapshot.json` is the text at export. If a spreadsheet program
changes a Current line cell (curly quotes, `- ` lines turned into formulas), the row still matches through the snapshot.

Not in this export: loading tips (`data/loading/loading_tips.txt`; the Oct 21 pass format still covers them), zone quiz
questions (trivia data, not dialogue) and `.speaker` name labels. `core/data/story_beats.gd` holds only scene ids and flags,
so it adds no rows.
