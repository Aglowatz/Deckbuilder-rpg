# Report - Overnight Oct 31 -> Nov 1 (Opus): the 8-part loop

Sat Oct 31 20:46 MDT ->. Tag `pre-overnight-oct31n` before the run. State `docs/loop_state.md`; questions `docs/overnight_inbox.md`, section
"Overnight Oct 31 - Nov 1". Last run's report: `docs/overnight/oct31_dialogue/overnight_report_oct30b.md`.

**Start-up**: the C: drive had 1.7 GB free. Deleted `builds/_export` (the unpacked copy of the v0.4.9 zip, re-made by every export) and the
Oct 30 `_screenshots/play` critic runs (gitignored, reports already written): 4.9 GB free. The v0.4.9 zip is kept.

## Part 1 - Housekeeping

- **a. Push**: `main` was already level with `origin/main`.
- **b. Sharded GUT**: `bash tools/run_tests.sh [--size=10] [--only=tests/core] [--from=K]` runs each 10 scripts in a fresh Godot process,
  one at a time, with one line per shard and a combined summary naming every failing test (logs `_logs/gut/shard_NN.log`, `summary.txt`).
- **c. Designer rewrites**: already applied on Oct 31 evening (657af1f1); a fresh export confirms the game text = the sheet (4203 rows, same
  IDs and order; only whitespace trims and the `{villain}` swap differ). Labels: Paste Works = Chef Marlo, `.rushed` = the Wanderer and Billie
  Muckfoot were already right; `fx.wake_outside` now reads "A gate guard" (exporter, `edit_oct27.csv` and the sheet's two cells).
  Baseline full run, sharded: **2506/2507 passed, 1 pending, 0 failing (30 shards, 19 min)**. The UI tests that failed only in a
  whole-suite run (focus/batch artefacts) all pass sharded, so the cause was the one long process; nothing to fix.
- **d. Answers 8-10 + two fixes** (tests in `tests/core/data/test_overnight_oct31n_part1.gd`, `tests/ui/test_scene_skip.gd`, `test_feats.gd`):
  - *Captain Spotless (8)*: until the gate opens he paces 1.8 m either side of his post on his new walk set (`SpriteStroller.pace` /
    `home_facing`; zone NPC entries take `pace`, `pace_until_flag`, `pace_sprite`), stays talkable (his talk spot follows him), and faces the
    road when back at his post.
  - *Esc on a first viewing (9)*: story scenes and cutscenes offer Esc every time; a first viewing asks "Skip this scene? You haven't seen it."
    (Skip / Keep watching). Skipping still sets every flag the scene sets.
  - *The Doppelganger (10)*: per-NPC reveal (`SpoilerFree.REVEALS`) - plate and boss intro "The Doppelganger" until the naming cutscene (or a
    freed Buffet), then "Grand Chef Escoffina". See inbox 1: the story names the apprentice "Escoffina", the real chef "The Grand Chef".
  - *Feats on load*: the bot snapshot had "Free the Gainlands" in the slot but not in the account record the Feats page reads (it was earned
    with saving off). Loading now copies the slot's feats into the account (no second reward), then re-checks state feats from the flags.
  - *Boss plate*: the name label grew past its box and ran under the heart (why the last size fit showed nothing). The name now sits in a
    clipping box sized to the band, at the largest size where every word fits whole; a boss phase goes on a gold caption above the band
    ("Phase Standardization" over "Primm"). Shots: `_screenshots/oct31n/plates_new.png` (before) / `plates_final.png` (after), tool
    `tools/plate_shot.tscn`. Three-word names ("Colonel Cornelius Crumb") get small (10 px) but stay inside the band.

## Part 2 - Music
(todo)

## Part 3 - Performance
(todo)

## Part 4 - Mid-game critic cycle
(todo)

## Part 5 - UX wish list + boss stall AI
(todo)

## Part 6 - Late-game + postgame critic cycles
(todo)

## Part 7 - v0.5.0 RC
(todo)

## Part 8 - Keep improving
(todo)

## Critic scores
| Area | Before | After |
|---|---|---|

## Test suite (sharded, full)

## New dialogue lines proposed
`docs/dialogue/new_lines_proposed_oct31.csv` (none yet).

## Art requests (not in game)
- Leaf Crown: the front view's arc ends point up like horns; a redo curving them round the head (answer 11: next art batch).
