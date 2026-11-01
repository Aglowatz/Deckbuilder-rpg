# Oct 31: the designer's answers to the critic pass, applied

The answers to the 14 inbox questions ("Dialogue critic pass", `docs/overnight_inbox.md`), and what was done.

| # | Answer | Done |
|---|---|---|
| 1 | The rewrites were typed over Current line | Found 37 rewrites in the sheet (all prologue/cave/Maren). The importer now applies a line typed over Current line (`tools/dialogue_edit_rows.js`); `edit_oct27.csv` rebuilt from the sheet (`sync_from_sheet.js`). 12 "designer line" fix suggestions (typos, the literal Primm, Path-ologists spelling) added; the one suggestion on a rewritten line was dropped. Voice bible section 1 rewritten from the rewrites. Not applied to the game: say "apply" (36 pass now; `cave_mouth.maren::0` needs its {villain} fix, Y on the critic row). |
| 2 | Paste them | New tab "Critic Oct 31" (217 rows: suggestion, why, category, priority, designer line, area, speaker). Dialogue Edit gained I "Critic suggestion", J "Accept (Y)", K-M why/category/priority (VLOOKUPs into the tab). |
| 3 | Do not restore, keep | The restoration suggestions stay as suggestions; no `--revert`. |
| 4 | Gatekeeper barks are after | Export labels say "after the gatekeeper is beaten" (`tools/export_dialogue.js`). |
| 5 | A good reveal moment | `lab_study_alone`: the desk has a child's drawing "For Papa, from {rescuer}." and the Wanderer says "Siphon is {rescuer}'s father. He held the door." |
| 6 | Only one time | `postgame.rescuer.freed::0`: "You came back for me. Down there, on purpose. I'm going to need a while to stop being cross about it." |
| 7 | Rewrite | `cutscene.wonder.6::1`: "You wore my face for ten years and never once learned to taste. Today you start. Let me give you something to start with." |
| 8 | Give her lines away | Druid Sorrel's lines (and the bridge's speaker/title in `core/zone/heap_growth.gd`) go to Moss Mulligan, freed. |
| 9 | Not deliberate | Rip's bark: shirt number two hundred and twelve. |
| 10 | Model Room; match; consistent names | "The Model Room" (title, blurb, before line, code comment); Trophy Hall rule text says "a 1/1 Reserve Guard joins" like its banner and token; hamster wheels "Gerald" -> "Nugget", "The Colonel" -> "Big Lou"; parlor -> parlour (prop, grave sign, Quest Log). |
| 11 | It is Plume | `facade.speaker.1.0.freed::0`: "The weather is no longer approved. It is just weather. It seems to be managing." |
| 12 | Edit as it makes sense | `{rescuer}` for the literal "Elowen" in `lab_study/steps/3`, `event.lab_cell4.body` (hand edits: the importer cannot compare a {rescuer} swap). The all-caps "THE SHOWCASE QUARTER" sign headings stay literal: a token would print "the Showcase Quarter" in lower case on a capitals-only sign. The two literal "Crosspath" lines in the Lab epilogue are critic Fix rows ({town}). |
| 13 | Make the recipes | Tri-Path crafting: `Alchemy.tri_problem/craft_tri/tri_path_pool`, `TRI_GOLD_COST` (300), `Session.craft_tri_card`; the Alchemist screen takes three Paths in the postgame; the "(no tri-Path recipes exist yet)" line now reads "The Alchemist's cauldron now takes three Paths at once: brew their essence into a tri-Path card." Uses the existing 32 tri-Path cards (card list unchanged). Tests in `tests/core/data/test_essence_alchemy.gd`. |
| 14 | Make it make sense; fix the labels | `tools/export_dialogue.js`: quest lines take their giver (the Paste Works is Chef Marlo's), `fx.wake_outside` is a Capital guard, `.rushed` Primm-fight variants are the Wanderer (as in game), "(corrupted)" dropped from labels, "Wren Muckfoot" -> Billie Muckfoot. Fixed in the sheet too (C/D). |

Game text changes went through `node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_oct27.csv --merge=docs/dialogue/fixes_oct31/merges.csv --apply`
(19 lines, in `docs/dialogue/edit_oct27/applied_ledger.json`, so `--revert` covers them) plus the four `{rescuer}` hand edits.

The Oct 21 batch regression dry run now prints 7 conflicts instead of 6: `cutscene.wonder.6::1` was rewritten here (expected).
