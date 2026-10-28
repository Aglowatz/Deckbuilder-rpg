# Overnight Oct 27-28 (Fable) - loop state (resume from here)

Start: Tue Oct 27 20:47 MDT 2026 (stop by ~05:45). Tag `pre-overnight-oct27` (= a5807ea1). Brief: the "OVERNIGHT - Oct 27 (Fable)" prompt
(Part 1 card decisions, Part 2 art direction review + master missing-art catalogue, Part 3 feats, Phase 2 polish loop, morning report).
Session model: Fable 5.1; if the allowance runs out or the connection drops, continue on Opus from this file. Questions go in
`docs/overnight_inbox.md` under "Overnight Oct 27-28". STOP_OVERNIGHT: a file named `STOP_OVERNIGHT` in the repo root stops the run at
the next part / cycle boundary.

Rules in force: one Godot process at a time, foreground, closed between runs; max 10-12 screenshots per part; GUT in groups
(`bash tools/gut_group.sh root|core|ui|world`); sims modest, one at a time (7.4 GB RAM); per part GUT + walkability + walk smokes +
`bash tools/perf_budget.sh structure` + commit + push; revert what can't pass; old saves keep loading; no enemy intent; NO image
generation (descriptions only); black market vendors and cards untouched.

**DIALOGUE FREEZE** (the user is editing `docs/dialogue/edit_oct27.csv`): never change, add, remove or reorder an existing dialogue line
or key in data/story/*, story_scenes.json, old_well_story.json, data/npcs/npcs.json, boss_intros.json, encounter_scripts.json,
dungeon_content.json, core/quests, story_beats.gd. New text = new keys only. Lines a change makes wrong go in
`docs/dialogue/lines_to_update_oct28.csv` (ID matching edit_oct27.csv, current line, suggested new line, why).

## Parts
| Part | Status | Notes |
|---|---|---|
| 0 setup | done | tag pushed, this file, inbox section |
| 1 Necrocrat units | done (set B: N-03 3/4, N-04 2/3, N-05 2/4, N-07 3/4, N-23 3/5, NEW N-38 Hazmat Intern 1/3 Toxic; L12 round robin N 45% two-seed mean; GUT root 276 / core 1465 / ui 234 / world 418 all green; commit a5c59207 pushed) | target: L12 round robin Necrocrat 40-50% overall, >=30% vs each Path, starters 80%+ in the cave, nothing over ~75%; log in balance_log.md + `docs/design/sheet_changes_oct28.csv` |
| 2 art direction + catalogue | done, commit d05586d9 pushed (GUT all four groups green except the then-unwired feats test) |
| 3 feats | done, commit 93ab2b47 pushed (feats 9/9, root 276, ui 234, core 1481 green; the world group run was killed by the harness for low memory with an orphaned Godot left, pid 7932 - rerun in the foreground once it exits) |
| Phase 2 | starting: loop_log.md; cycles: stability (world GUT, playtest smoke, story bot), boss-intro shadow polish, scorecard | `docs/overnight/loop_log.md` |
| report | pending | `docs/overnight_report.md` |

## Part 1 notes
- Baselines (Cards Oct 27, no code change since): L12 round robin Necrocrat 20% (seed 7000, 20 games) / 33% (seed 8100, 20 games);
  vs Gourmand 10% on both seeds. Reports `docs/design/sim/cards27_decks_l12_*.md`.
- Sim: `Godot_console --headless --path . -s res://tools/run_balance_sim.gd -- --what=decks --level=12 --games=20 --seed=8100 --out=res://docs/design/sim/oct28_decks_l12_<x>.md`;
  the cave: `--what=tutorial --games=25 --seed=7000|8100`.
- CSV edits: `_logs/necro_oct28_apply.js` (byte-exact writer, same as `_logs/cards_oct27_apply.js`), then `bash tools/import_cards.sh --stamp` and `--write`.
