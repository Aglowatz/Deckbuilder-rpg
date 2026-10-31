# Report - Overnight Oct 30-31 (Opus): eight improvements + v0.4.9

Fri Oct 30 22:13 -> Sat Oct 31 ~02:15 MDT. Tag `pre-overnight-oct30b` before the run. State `docs/overnight/loop_state.md`; questions
`docs/overnight_inbox.md`, section "Overnight Oct 30-31". Last run's report: `docs/overnight/oct30/overnight_report_fresh_eyes_round2.md`.

Rules kept: the dialogue freeze (no line or key changed, added, removed or reordered; nothing needed a rewrite, so no
`lines_to_update_oct31.csv`); no art generated; no enemy intent (the new previews only play out the player's own action); prices, the XP
curve, starters and bosses unchanged (boss sims run, no change); no mulligan, no boss clock; the black market untouched (its dealer's reach
and stock as before). Old saves load: two new settings keys with defaults, new save flags only (`scene_seen_*`, `cutscene_seen_*`).

## Read this first

- **All eight parts landed, and v0.4.9 is built**: `builds/TheWaywardPath-v0.4.9-windows.zip`, **762 MB** (798,372,807 bytes; pack 850 MB), guarded export OK, release smoke on the exported pack PASSED on D3D12 at Medium and Low, tour bot 0 errors, story bot 90/90, every smoke OK. Notes for testers: `docs/release/v0.4.9_notes.md`. The v0.4.8 zip was deleted after the new one passed (v0.4.7 was already gone).
- **The mid-game critic (rerun from a real-progress save) scored 5.5 / 10** (the first mid-game critic, from a weaker snapshot: 5.2).
  Its top problems were repeated beginner tips, unexplained HP pools, bosses that walled its simple battle bot, and twists given away by
  names. **Nine of its fifteen were fixed** (table below); the boss "walls" were checked in the sim (in band for the expected decks).
- **New for players**: a goal pointer everywhere (gold main line, blue side quest), sprint and fast travel from the map, a preview of what
  your aimed card will do, dialogue that any key advances with a dimmed listener and Esc-to-skip on replayed scenes, a Deck Station with a
  cost curve, "works well with" and Suggest a deck, quiet dungeon ambience, louder-where-it-should-be sound effects.
- **Loading**: coming back to Crosspath from a zone 7.2 -> 6.0 s; the first arrival and the zones are unchanged (an attempt to load the
  next scene on a thread made things worse on this PC and was dropped). This PC's load times swing by ~4 s from run to run.
- **One thing that went wrong**: from ~22:20 to ~22:40 the critic's game runs loaded my untested work-in-progress for Parts 2-8 from the
  working tree. I stashed it as soon as I noticed; no run logged a script or parse error. The critic's findings are about the shipped game.

## By part

| Part | State | Commits | What |
|---|---|---|---|
| 1 Mid-game critique | done | ae33e08e, 479ee8f2, f1666de8, 02d53ced, c2590aaf, c457d729, 0ee91f96 | story-bot snapshot, critic 5.5/10, triage, 9 fixes |
| 2 Goal pointer | done | 28c058d6 | two goals per area, arrows, ground rings, map dots, legend, setting |
| 3 Less walking | done | 9b7528d7 | sprint (Shift / L3 / Always sprint), map fast travel |
| 4 Attack previews | done | b3c1e0dd, 5eb21f37, 653cb843 | the player's own aimed action played out on a clone; HP left |
| 5 Faster loading | partly | 26611b07 | return to town -1.2 s; zones unchanged |
| 6 Dialogue presentation | done | 35f84069, 0ee91f96 | any key, per-letter voice, listener portrait, Esc skip on replays |
| 7 Smarter Deck Station | done | 089169e1 | curve, mix, rarity / New filters, works-well-with, Suggest a deck |
| 8 Sound pass | done | a434016b | gap audit, dungeon beds, new sounds, ebur128 loudness by category |
| 9 v0.4.9 | done | (final commit, tag `v0.4.9`) | all bots and smokes, bump, guarded export, exported smokes, zip, notes |

### Part 1 - the mid-game critic, fairly this time

**The snapshot**: `bash tools/run_story_playthrough.sh --snapshot_after=2 --snapshot=midgame_real` plays the story with the bot (the cave,
Maren's chain, Brannoch, the Gainlands and the D.N.A. with their favours, side and main dungeons and memories), then gives the expected
player's level 13, deck (`ProgressionModel.reference_deck`), gear, items and gold (600) and saves `midgame_real`. A new critic subagent
(brief `docs/review/critic_brief_midgame_rerun_oct31.md`, no project docs) played 15 runs in ~40 min: packs, Deck Station, Character,
quests, the Buffet and the Test Kitchen to the Doppelganger, the freed D.N.A., the Dump and Compostella, the Capital, Vivienne Quota and
Primm's first phase, Omakase's map. Report: `docs/review/fresh_eyes_midgame_rerun_oct31.md` (46 shots).

| Area | Score | Area | Score |
|---|---:|---|---:|
| Clarity | 4 | Story and humour | 6 |
| Pacing and friction | 5 | Visual cohesion and readability | 7 |
| Combat depth and feel | 5 | UI/UX consistency | 4 |
| Deck-building | 6 | Audio | n/a |
| Reward rhythm | 5 | Performance | 6 |
| Exploration and world | 6 | Bugs | 5 |
| | | **Overall** | **5.5** |

Its top 15 and what happened (triage `docs/review/fresh_eyes_midgame_rerun_triage_oct31.md`):

| # | Problem | Verdict | Tonight |
|---|---|---|---|
| 1 | Beginner tips fire again at L13 and block the turn | valid (the bot's save never saw them) | **Fixed**: the eleven first-duel tips count as seen past level 5 or a freed zone |
| 2 | HP small and different on every screen | partly (each pool is a rule) | **Fixed**: the HP bar says "Max 11 here (-5, hover)" and the tooltip lists why |
| 3 | Bosses are walls at L13 | partly (the critic's battle bot) | Sim: Doppelganger 47 %, Compostella 66 % for the expected decks - no change |
| 4 | No healing across 13 nodes | conflicts (zone HP is the design) | No |
| 5 | Names spoil twists | valid | **Fixed** (`SpoilerFree`): cover names on plates and the "Boss:" line |
| 6 | "Go to Crosspath" inside every zone | valid | **Fixed**: a zone tracks its own main line on arrival (+ Part 2's second goal) |
| 7 | Vendors don't open on E | valid (reach 1.8 m, chatter 3.2 m) | **Fixed**: shopkeepers answer from 2.8 m, town and zones (not the black market) |
| 8 | Boss intros long on every retry | partly | **Fixed**: Esc skips a scene or cutscene seen before (flags still set) |
| 9 | Maps fogged, name nothing | valid (fog by design) | **Fixed**: every revealed place named on the map; goals in the legend |
| 10 | Arrival popups block input | partly (operator lines are dialogue) | No |
| 11 | Same 13-node dungeon shape | conflicts (dungeon list import) | No |
| 12 | Feats not back-filled | partly (bot flags) | No (inbox) |
| 13 | Stale "Needs 4 energy", nameplate clip | valid | **Fixed** (the why-not line follows the game); nameplate: tried, reverted, inbox |
| 14 | Deck Station hard to read | partly | **Fixed** in Part 7 (and its first tip moved off the filters) |
| 15 | Greybox / stand-in art | valid, needs art | No (art) |

Shots: `docs/review/overnight_oct31/p1_*` (Sable's stall now opens on E; the Capital's HP caption).

### Part 2 - goal pointer everywhere

`QuestMarkers.goal_targets` picks up to two goals per area: the tracked quest's step, then the other kind's (a main line while a side quest
is tracked, the most recent side quest while a main line is), each pointing at its spot, at the road toward another area, or at the NPC to
hand it in to. `QuestMarkerLayer` draws a spinning chevron and a pulsing ground ring for each (gold main, blue side), two edge arrows
(`QuestEdgePointer.color`), and map dots that show through the fog and clamp to the minimap's edge; the full map lists the goals by quest
name. A new goal makes a soft sound. Settings > Display > Goal pointer turns it all off (the "!" / "?" stay). Town, every zone and the
Capital (all walkable areas use the layer); the forest keeps its cave beacon. Test `tests/core/quests/test_goal_targets.gd`; shots
`p2_*`.

### Part 3 - less walking

Sprint: hold Shift (a new bindable "Sprint (hold)" action), 1.65x; a controller's left-stick click sprints until the hero stops (the
camera zoom's pad default moved to Share/View); Settings > Controls > Always sprint; never on a mount or while thrown. Fast travel: M >
**Fast travel...** opens the Rift Express list and goes straight to any reached station (Crosspath, the zones' towns, the forest
postgame; never a dungeon); a freed zone counts as a reached station. Walkability and encounters are unchanged (the same movement code;
all walk smokes OK). Test `tests/world/test_sprint_and_map_travel.gd`; shot `p3_map_fast_travel_list.png`.

### Part 4 - attack previews (the player's own action only)

`CombatPreview.predict_action` plays the aimed card, ability or Resource out on a clone of the game (the opponent's face-down traps left
out, as the attack preview already did) and reports, per changed unit, damage, HP left, death and new stats, and damage or healing per
hero. While aiming (including a hand card's decision chain on its last single-target step) the target shows a badge: "-2  3 left", a
skull, "+2/+1 -> 4/3" (green; a debuff violet), and the hero plates "-N HP LETHAL!" or "+N HP". Attack / block badges also show the HP
left. Nothing of the enemy's is played or read. Tests `tests/core/game/test_action_preview.gd` (damage, lethal, player lethal, buff, the
opponent's action refused, an illegal target) and `test_combat_preview.gd`. Shot `p4_aim_preview_lethal.png` (`--aim=N` battle shot flag).

### Part 5 - faster loading

Full method and table: `docs/perf/report.md` ("Faster loading"). Real path, Medium, `LOAD_TIMING=1`, fade-out to fade-in:

| Load | Before (two runs) | After | Change |
|---|---:|---:|---|
| Crosspath, first arrival of the session | 8.4 / 8.3 s | 8.1 s | ~same (the first screens are built under the cover once per session, ~1.7 s, on purpose) |
| The Verdant Dump | 7.3 / 6.7 s | 6.7 s | same |
| Crosspath, back from a zone | 7.1 / 7.2 s | **6.0 / 6.0 s** | **-1.2 s** |
| Worst frame in the 5 s after the fade-in | 30-68 ms | 36-49 ms | no new hitch |

What changed: the ~250 files of the first seconds in town are asked for on loader threads as soon as the actors and enemies exist (they
were asked for at the end of the build and the reveal waited 1.2-1.7 s), and the reveal no longer waits for the menu paintings (they
keep arriving on threads). Tried and dropped: loading the next scene on a thread during the fade-out (contention: Crosspath 8.3 -> 13 s).
This PC swings ~4 s between identical runs (slow runs spend ~5 s in "painted: swaps"), so every number was measured twice. The zones'
builders are the next lever (inbox 12).

### Part 6 - dialogue presentation

Any key completes the line, then advances (`DialogueBox.is_advance_key`: not Esc, the F keys, Tab or a lone modifier). The voice blips
follow the letters as they appear (one every two letters, at most every 45 ms, from each speaker's pitched voice) and stop when the line
is complete or skipped (the old timer kept ticking after a skip). In a back-and-forth (two conversations within 0.7 s, as every scene and
arrival chains them) the last speaker stays on the opposite side as a dimmed listener while the new one slides in bright; expression tags
switch the portrait as before; the typewriter speed is Settings > Text. Esc skips a scene seen before (critic #8). Tests
`tests/ui/test_dialogue_presentation.gd`, `tests/ui/test_scene_skip.gd`.

### Part 7 - a smarter Deck Station

`DeckInsights` (core): the cost curve, the Path mix, the type counts, themes read from each card's rules (the Resource it makes or uses,
the Refuse Pile, tokens, keywords, Tool / unit), "works well with" (a maker and its users score highest; other Paths count less) and
`suggest(owned, paths, level, infrastructure, size)`: owned copies within the level's caps, a cost curve (0-1 / 2 / 3 / 4 / 5+), units
first, the Paths' own cards before Colorless, Infrastructure split by pips. The station: the curve beside the rule rows (the deck list
keeps its height), a "Beefcake 39, Colorless 6 | Units 21, Spells 2 ..." line, rarity and New filter chips, "Works well with" in the
hovered card's preview, and **Suggest a deck** (the main Path, any Path with 8+ owned cards, pairs when two Paths are allowed). Test
`tests/core/deck/test_deck_insights.gd`; shots `p7_*` (the first try squeezed the deck list to one row: `p7_before_list_squeezed.png`).

### Part 8 - sound pass

Audit and changes: `docs/audio/sound_gaps_oct31.md`. Dungeon maps had no ambience (now a quiet bed per dungeon from its zone's sets); new
`goal_update` and `sprint_start` built from existing sounds; previews, map travel and the Deck Station use existing ones. Loudness:
`node tools/sfx_loudness.js` (ffmpeg ebur128, the loudest momentary loudness of each event as played) - 21 outliers moved toward their
category's median (Battle spread 9.0 -> 7.3 LU, UI 9.4 -> 7.6, Resources 8.9 -> 7.9); `docs/audio/loudness_oct31_before.md` / `_oct31.md`.
Sound check: 170 rows, 0 silent, one event over -1 dBFS (`thrower_land` -0.9, as before).

### Part 9 - v0.4.9

| Step | Result |
|---|---|
| Tour bot | OK - 281 spots, 9 menus, 5 battles, 0 errors, 0 warnings |
| Story playthrough bot | 90 / 90 |
| Smokes | playtest (opening hour) OK, gamepad OK, prologue OK, first battles OK (lowest 57 fps), release OK, walk smokes Crosspath / hub / Gainlands / D.N.A. / Buffet / Dump / Capital OK, memory round trip OK (Part 5, 6 trips: static +1.0 MB, video +0.9 MB), structure budget OK |
| GUT | root 286, core 1518 + 1 pending, ui 258, world 428 - all green |
| Frame budget (windowed Low + Medium) | **not completed**: Claude Code stopped the run because the PC ran low on memory while it was going (its last probes finished on their own); not restarted. The fps seen tonight in smokes and probes (57+ in battle, 64-72 in zones) match the last budget run |
| Version | 0.4.9 (`project.godot`, `export_presets.cfg`) |
| Guarded export | EXPORT OK: pack 850 MB, zip 762 MB (798,372,807 bytes; under the 850 MB flag), CRCs checked; peak memory import 1042 MB, export 1608 MB |
| Exported release smoke | PASSED on D3D12 (AMD Radeon iGPU) at Medium and at Low |
| Zip | `builds/TheWaywardPath-v0.4.9-windows.zip`; v0.4.8 zip deleted after the pass (v0.4.7 already gone); 3.7 GB free on C: |
| Notes | `docs/release/v0.4.9_notes.md` (everything since v0.4.6 in player terms, tonight's work, "What we'd love feedback on", saves carry over) |

## Inbox

`docs/overnight_inbox.md`, section "Overnight Oct 30-31".
