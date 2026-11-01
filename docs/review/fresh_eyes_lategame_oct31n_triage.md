# Triage - late-game critic, Overnight Oct 31 -> Nov 1 (first score ~4.5/10)

Report: `docs/review/fresh_eyes_lategame_oct31n.md` (85 min, 16 runs, `lategame_real` (L20, four zones freed) and its own saves; the ending
and Phase 3 were not reached; most fights played by the driver's weak `pilot`).

| # | Problem | Verdict | Action |
|---|---|---|---|
| 1 | Primm's intro "soft-locks" on its last line | **valid** - the text froze mid-word and only Esc answered: the scene had stopped processing (the tree paused under it); one run before, an Esc on a dialogue box opened the pause menu over the scene and E then pressed pause buttons | **Fixed**: cutscenes run with PROCESS_MODE_ALWAYS and block the pause menu while up (Esc is their skip; a static counter restores it after the last). An E-only repro (before the fix) advanced through all six beats and the scene closed (`docs/review/play_scripts/oct31n_fix_primm.txt`); the freeze did not reproduce here, so the fix makes the scene immune to the pause rather than chasing one trigger |
| 2 | No clear route to the Capital | valid, mostly text | Quest-log wording is frozen dialogue; inbox. ("Where to?" now lists every place incl. the Undercroft hatch.) |
| 3 | "Free the Four Zones" still the title after four | design (its 5th step is the castle) | Inbox (rename = quest text) |
| 4 | "Broken services 0 of 4" outside vs "4 of 4" in battle | **valid bug** - the battle built the panel from `{}` | **Fixed**: the battle reads the session's flags |
| 5 | Invisible HP drain in the Capital | design (Capital debuffs/inspections) | Inbox: name the source in the toast, heal at the Crease |
| 6 | Lieutenant / Primm outlast the pilot | balance (sims: Primm phases 83-100 % for the expected deck) | Inbox; the pilot is weak |
| 7 | Hands flooded with basic infrastructure | design (deck auto-fill 16-20) | Inbox |
| 8 | Final dungeon long on one HP bar | design | Inbox |
| 9 | Narration labelled Primm; story box over the boss card | partly | Inbox (speaker mapping is story data) |
| 10 | Placeholder icons in the phase transition | art | Art list |
| 11 | Three dialogue styles and keys | partly | Pause menu can no longer open over a cutscene (fix 1); rest inbox |
| 12 | The Capital's look on arrival | art/look | Inbox |
| 13 | Map would not close while a "tooltip" showed | likely the "Where to?" dropdown's popup holding the driver's keys | Logged; next pass: close the popup on Esc / M |
| 14 | Talk prompts that do nothing (Spotless, gate open) | needs a repro | Logged for Part 8 |
| 15 | "Carried out of the dungeon" after an overworld fight | **valid** | **Fixed**: that line only inside a dungeon run, else "You come to, a little bruised." |

Tests: `tests/ui/test_lategame_fixes_oct31n.gd` (3).
