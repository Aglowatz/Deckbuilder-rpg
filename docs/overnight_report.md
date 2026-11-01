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

## Part 2 - Music (done)

- **The overlap fix** (`tools/music/lib/score.py` `note_spans`, unit test `tools/music/tests/test_note_spans.py` 5/5): a re-strike of a pitch
  that was still sounding on the same channel used to be cut off by the earlier note's note-off. Per pitch and channel, notes now merge
  so each sounds its full written length.
- **All 144 re-rendered** (`bash tools/music/rerender_all.sh render`): 100 tracks changed audibly (>= 5 % more sounding note time: pads,
  organ, tremolo strings, choirs; up to +65 %), 19 slightly, 25 not at all. Per-track notes: `docs/audio/music_overlap_fix_oct31.md`.
- **Rules held**: loops -20 LUFS; three seams went over 1.5 dB once their held notes rang through the end and got `Score.soften_tail(0.85)`
  (MUS-CAP-REF-BROKEN +1.66 -> +0.47, MUS-MINIGAME-NECRO +1.51 -> -0.54, MUS-TUT-EXP +1.60 -> -0.51 dB); one-shots onset-checked.
- **Delivered**: old files backed up as `Superseded/Music_v01/<ID>_orch-v1b.ogg|wav` (144), new ones approved as revision `orch-v2`,
  "import audio" (in game 142, missing 0), boss victory stings re-cut, `docs/audio/music_integration.md` refreshed. Audio GUT 90/90, music
  smoke OK (worst crossfade step 0.00 dB). Previews of 10 tracks: `Music Review/Overlap fix/`.
- The import's background shell was stopped by Claude Code's low-memory guard after it had copied the files; its own Godot re-import
  finished on its own, and the remaining steps (sting cut, doc) were run in the foreground.

## Part 3 - Performance (partial: frame budget done, loading measured but not cached)

Details: `docs/perf/perf_oct31n.md`.
- **Quiet frame-budget run**: every average inside budget; after re-running the four areas whose first-pass 1% low was over, every 1% low
  inside too (v0.4.9's run had 14 over, taken under memory pressure). Steady over: Crosspath Medium draw calls 874 vs 840 (frame time fine).
- **Deck Station**: 7.6 ms avg / 10.7 ms 1% low quiet (the 21 ms was memory pressure). **Goal pointer second marker**: no cost (A/B).
- **Thorn wall**: 103 mesh nodes -> 19 (spikes and vines as MultiMeshes); hub walk smoke OK cold and warm.
- **Loading** (warm): town -> Dump 6.6 s, Dump -> town 5.5 s. The big steps left are model instancing (kept out of the cache by the Oct 25
  decision) and `HeapLayout.build` (641 ms, needs serialising ~15 object kinds): logged as the next lever, not done tonight.

## Part 4 - Mid-game critic cycle

Full write-up: `docs/review/midgame_cycle_oct31n.md`. Save: `midgame_real` (story bot, Oct 30-31: cave,
Maren's chain, the Gainlands and the D.N.A. freed with their dungeons, L13 expected deck/gear). Critics play from a worktree at the last
commit (`/c/Dev/wp_critic`, import cache hard-linked: no extra disk).
- **First critic: 4.8/10** (52 min, 28 runs; `docs/review/fresh_eyes_midgame_oct31n.md`). Triage: `docs/review/fresh_eyes_midgame_oct31n_triage.md`.
- **Fixes (df634833)**: the "frozen" boss intro (clicks on the cutscene's text panel were swallowed), energy codes in plain tooltips,
  "units and spells", Esc closes the topmost Deck Station popup first, deck-test events state the test and your odds before the reveal
  ("the well stays silent" only at the well), "Where to?" names every place (revealed or not) and pings it through the fog, empty-filter
  note, the Rotheart's "Overgrowth" renamed "Wild Growth", toasts wait while a reward pick is up, a "X is free" banner in freed zones.
- **Second look: 5.5/10** (fresh critic, same save; `docs/review/fresh_eyes_midgame_oct31n_second.md`).
- **After the second look**: Sable reachable (vendor reach = her bark range 3.24 m; prompts name who answers), clicking another hand card
  leaves "Choose a target", Quit Game asks and saves, "Open all" packs with one summary. Its big remaining items are design calls (inbox 9):
  the Buffet/Dump difficulty wall for a two-zone deck, the 13-card hand layout, boss tempo.

## Part 5 - UX wish list + boss stall AI (done except the D.N.A. lobby dressing)

Tests: `tests/ui/test_overnight_oct31n_ux.gd` (4), `tests/core/ai/test_ai_stall_rule.gd` (3). Shots: `_screenshots/play/p5_ux2/`
(`p5_02b_map_ring`, `p5_07b_node_hover`), `_screenshots/play/p5_ux/p5_03_where_to_open.png`, `_screenshots/p5_locked_slots2.png`.
- **Map**: names were already under every icon (Oct 30-31). New: a **"Where to?"** list in the legend (dungeons first, then vendors, healers,
  the Arena, quest givers, challengers, exits; one per name) that pings the picked place for 4 s; the **dungeon entrance** draws bigger on a
  red-gold ring.
- **Locked gear slots** print "Opens: armory quest" ("Finish the armory quest" while it is active) above each padlock.
- **Dungeon nodes**: an open node's preview ends with "Click again to go." (pad: "Press A to go.").
- **HP pool banner**: arriving in a zone whose max HP differs from your usual says so once per visit ("Max HP here: 11 (your usual 16;
  -5 Famine)"). The Capital's HP panel already showed "Max 11 here (-5, hover)".
- **Boss stall AI (answer 7)**: from turn 9, while the AI has no unit on the field or nobody has lost any HP, its 4th+ Tool / Wonder counts
  15 % of its worth, so it deploys a unit instead (`AIEvaluator.is_stalling`; not a clock). Sims (`docs/design/sim/stall_oct31n/`, 3 games
  per Path, every boss): bare starter and built deck, rule off vs on - **identical win rates and lengths** (the sim's player attacks every
  turn, so no stall forms and the rule never fires); Vivienne Quota at L8 with the bare starter, 8 games per Path: identical (25 %). So no
  band moves; the rule only changes a genuinely stalled board (unit test). `--starter` added to the balance sim; `WAYWARD_STALL_RULE=off`
  for A/B. Infrastructure was left alone (devaluing a 5th land risks the AI holding lands in hand).
- **D.N.A. lobby dressing**: not done yet (left for Part 8).

## Part 6 - Late-game + postgame critic cycles

- **Saves (story bot, a6299c9c)**: `lategame_real` (L20, the four zones freed, 1200 gold, 47 cards) and `postgame_real` (L23 after Primm,
  49 cards). 150+ bot checks passed, none failed. The bot runs were stopped twice by the low-memory guard as background shells; their Godot
  kept going and finished (waited on in the foreground).
- **Late-game critic: ~4.5/10** (85 min, 16 runs; did not reach Phase 3 or the ending; `docs/review/fresh_eyes_lategame_oct31n.md`, triage
  `_triage.md`). **Fixes (9c3a0181)**: cutscenes keep running under a pause and block the pause menu while up (Primm's intro froze
  mid-line, only Esc answered), the Capital battle panel reads the real services (it said 4 of 4 broken from an empty dict), "carried out of
  the dungeon" only inside one. Second look: not run (the RC came first; see Part 8).
- **Postgame critic: 3.5/10** (55 min, 13 runs; `docs/review/fresh_eyes_postgame_oct31n.md`, triage `_triage.md`). **Fixes**: NPCs answer
  from beside them, not only from the point in front (Old Man Mountain gave no prompt from his side - so Swolympus looked sealed; same for
  Spotless); the zone HP panel and the HP banner no longer call gear "here" (the -7 was the expected L23 gear). Loose Ends quest / boss
  tuning / freed-zone healing are design calls (inbox).

## Part 7 - v0.5.0 RC (done, not shared)

- **Build**: `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v0.5.0-windows.zip` - **762 MB** (798,770,733 bytes; payload 849 MB before
  zip). `tools/export_windows.sh 0.5.0`: EXPORT OK (pck MD5s, baked shaders, zip CRCs). Version 0.5.0 in project.godot / export presets;
  CHANGELOG entry. Not uploaded or shared. The v0.4.9 zip is kept beside it.
- **Build smoke on the exported pack**: release smoke PASSED (title with v0.5.0, New Game -> the forest, F8 report, pause menu version,
  manual save -> load with gold back); the playtest bot on the exported test pack OK (forest, Path choice, the cave, Maren, merchants and a
  card, Deck Station, the store room ghosts fight, level 5, Bertram's quest; auto-win through the real result screen; no SCRIPT ERROR).
  The exported runs do not log music, so the title cue and the victory sting rest on the pck's MD5 check plus the in-editor music smoke on
  the same files (Part 2: OK).
- Done before Part 6's second looks (a safe order: the RC exists whatever happens to the rest of the night). The critic worktree was
  removed for disk space during the export (2.3 -> 4.3 GB free) and is re-created for the next critic.

## Part 8 - Keep improving

- **Cycle 1 - late game second look: 4.6/10** (from ~4.5; reached all three Primm phases, the ending and the credits, phases 2-3 with
  autowin; `docs/review/fresh_eyes_lategame_oct31n_second.md`). Its top items: the ending's icon stages (art), the placeholder credits (your
  answer 3: kept), Primm phase 1 a wall for the pilot, the rule "every unit is a 3/3" vs buffed units (rewording proposed in
  `docs/dialogue/new_lines_proposed_oct31.csv`), "Broken services: 0 of 4" read as no progress. **Fixed**: the counter now reads
  "Services restored: N of 4" (chip and panel).
- **Cycle 2 - postgame second look: 4.0/10** (from 3.5; `docs/review/fresh_eyes_postgame_oct31n_second.md`). Still: nothing after the credits
  says what is left (Loose Ends = design call), Siphon a wall for the pilot (48 HP vs 14, drains each turn), the Swolympus route hard to
  find, flat summit pay-off. **Fixed**: Siphon's rule no longer promises Elowen when she was not rescued in the run. A gate marker for
  the sealed trailhead was tried and reverted (an earlier decision: the gate never opens; Old Man Mountain is the way, and he is listed).
- **Suite after the cycles**: core 1534 + 1 pending, world 431, ui 194 (Nov 1 05:30), all passing.

## Critic scores
| Area | Before | After |
|---|---|---|
| Mid game (Part 4) | 4.8 | 5.5 |
| Late game + ending (Part 6) | ~4.5 | 4.6 |
| Postgame (Part 6) | 3.5 | 4.0 |

## Test suite (sharded, full)

- Start (before tonight's changes): 2506/2507 passed, 1 pending, 0 failing (30 shards, 19 min).
- After Parts 1-7 + the postgame fixes (Nov 1 03:47): **2540/2541 passed, 1 pending, 0 failing** (ui 194, audio 90, characters 4, root 287,
  core 1534 + 1 pending, world 431).

## New dialogue lines proposed
`docs/dialogue/new_lines_proposed_oct31.csv` (none yet).

## Art requests (not in game)
- Leaf Crown: the front view's arc ends point up like horns; a redo curving them round the head (answer 11: next art batch).
- Stills (or portraits) for the cutscenes that still use the icon stage: Primm's phase transitions and most of the epilogue, the
  Doppelganger's reveal (chef hat / wizard hat glyphs). Three critics flagged them as placeholder right after the painted art.
- The D.N.A. lobby and the Capital's Crease / Gate Road read as greybox (critics); dressing from existing kit pieces was not done tonight.
