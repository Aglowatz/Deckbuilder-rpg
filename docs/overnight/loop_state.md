# Overnight Oct 28-29 (Opus) - loop state (resume from here)

Start: Wed Oct 28 20:15 MDT 2026 (stop by ~05:15). Tag `pre-overnight-oct28` (= 9bdb73e5). Last run's state: `docs/overnight/oct27/loop_state_oct27.md`.
Brief: the "OVERNIGHT - Oct 28 (Opus)" prompt (Part 0 inventory, Part 1 Maren + roaming enemies, Part 2 boss entrances + Bestiary,
Part 3 verify the art, Part 4 battle feel, Part 5 memory leak, Phase 2 polish loop, morning report `docs/overnight_report.md`).
Questions go in `docs/overnight_inbox.md` under "Overnight Oct 28-29". STOP_OVERNIGHT: a file named `STOP_OVERNIGHT` in the repo root
stops the run at the next part / cycle boundary. If time runs short: cut Part 5, then Part 4 - never the art.

Rules in force: one Godot process at a time, foreground, closed between runs; max 12 screenshots per part; GUT in groups
(`bash tools/gut_group.sh root|core|ui|world`; 7.4 GB RAM); per part GUT + walkability + that area's walk smoke + `bash tools/perf_budget.sh`
+ commit + push; revert what can't pass; old saves keep loading; no enemy intent; NO image generation; never read Drive `Pending Review`
or `Replaced Artwork - Batch 1 - Oct 28`; Drive is copy-only (never move/rename/delete); black market vendors untouched.
**DIALOGUE FREEZE** (the user is editing `docs/dialogue/edit_oct27.csv`): never change, add, remove or reorder an existing dialogue line
or key; new text only in new keys. No version bump, no export.

Art in scope: rows #1-74 of `docs/art/art_batch_oct28.csv` (Maren portraits + sprites, 21 SPR-FOE sets, 26 CUT-*, 23 BST-*).
Batches 5-9 are NOT made: build no hooks for them. Inventory + import log: `docs/art/import_oct28.md`.

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 0 Inventory | done 20:45 | afeb463e | 239 files sound; assets/art 365 MB before |
| 1 Maren + roamers | done 21:45 | afeb463e | 21 FOE sets + ELDER; lineup tool; threat/hop/rim; ZoneEnemy drives actor |
| 2 Entrances + Bestiary | done 21:45 | afeb463e | 27/31 entrances on CUT-*; Primm phases; 24 squares |
| 3 Verify | done 22:30 | (see git log) | bots + smokes OK except hub (Hob on the line, inbox 4); payload 793.7 MB, zip ~750 |
| 4 Battle feel | in progress | | |
| 5 Memory leak | | | |
| Phase 2 | | | |
| Morning report | | | |
