# Overnight report (Oct 16-17)

Brief: quest overhaul, 25 equipment pieces, the hub world and the Undercroft, the dialogue rewrite, a playthrough bot. Rules: commit + push per part,
STOP_OVERNIGHT file stops the run, `docs/overnight_inbox.md` is read before each part, one Godot at a time. Start tag: `pre-overnight-oct16`.
Decisions: `docs/design/open_questions.md` "Overnight decisions (Oct 16)" (ON-*). The previous overnight report moved to `docs/overnight_report_oct13.md`.

## Status

| Block | State |
|---|---|
| 1 Quest system overhaul | done (see below) |
| 2 Equipment and loot | done (see below) |
| 3 Hub world and the Undercroft | done (see below) |
| 4 Dialogue rewrite | done (see below) |
| 5 Playthrough bot, hitches, report | done (see below) |

## Block 1: quests (done)
- Data model: category MAIN/SIDE, ordered objectives with targets (kind, area, spot, "where to go"), step rewards (milestones), completion rewards in
  any combination, giver/turn-in areas and spots. Built in code (`QuestCatalog`), no generated .tres. Doc + full reward table: `docs/design/quests.md`.
- Each Path zone has a MAIN line (gatekeeper -> cross in -> a favour -> main dungeon) paying a Path Pack at the gatekeeper and at the end and a piece
  of gear at the midpoint; Brannoch gives "Free the Four Zones" (open Capital, castle warning while services are broken).
- Tracker: one quest, MAIN/SIDE tag, checklist (done ticked, current highlighted), `[` / `]` (rebindable) and LB/RB toggle, follows the most recently
  updated quest; the "Crosspath - N of 4" header is gone; zone effects and the Capital's broken services are collapsible chips.
- Quest Log (J): Main / Side / Completed, track by click or Enter, details (summary, checklist with step-reward icons, giver, where to go, rewards with
  pack art and equipment icons), keyboard Left/Right/Up/Down/Enter.
- Markers: "!" / "?" over givers in the world and on the minimap/full map; one golden objective chevron + ground ring for the tracked quest (on the
  minimap, clamped to its edge; drawn under fog); a soft edge-of-screen pointer when off-screen.
- Gatekeepers: names + epithets (`Gatekeepers`), their zone's battleboard and Path combat song, blocked/cleared lines per obstacle; obstacles
  themselves are built in Block 3.
- Passage camera: 12 percent pull-back (Block 3e done early).
- Tests: `tests/core/quests/test_quests.gd` (model, milestones, migration x3, cycling), `test_quest_markers.gd`. Windowed smoke:
  `bash tools/run_quest_smoke.sh` (town + Gainlands + D.N.A.; passes). 1647 GUT, all passing.

## Block 2: equipment (done)
- 25 pieces in `core/data/expansion_gear.gd` (5 weak early, 4 resource generators, 4 strong with drawbacks, a buff per Path, 5 keyword pieces,
  a draw trinket, an XP trophy, Gotta-Go Galoshes +35 % overworld speed); all through Modifiers (two new kinds read outside battle).
- Distribution: every main and side dungeon's first clear pays one; the four main-quest midpoints, Meet the Merchants and Juice the Station pay
  one; each zone shop has a "Gear" button with 2-3 pieces (Path pieces after the zone is free); Bertram sells two cheap early pieces; hidden chests
  and dungeon treasure roll gear or packs by tier (`ChestLoot`). Table: `docs/design/equipment.md`; icon rows: `docs/art/zone_kits/equipment_icons.md`.
- Comparison tooltips (`EquipmentCompare`): shops and the character screen's piece picker show the stat differences and what you would lose.
- Tests: `tests/core/game/test_expansion_gear.gd`. 1657 GUT passing.

## Block 3: the hub world (done)
- One country, no sea (`world/hub/hub_land.gd`): painted land to the horizon, the town lake and two country lakes, five themed roads to the
  horizon, a tree belt that hides the old rim (never in the camera's way), rim blocks turned to trees, hex tiles hidden, haze and backdrop rings.
- Obstacles with cleared states and animations (`hub_obstacles.gd`): gorge bridge, permit barrier, pantry door, thorn wall; gatekeepers at them,
  Brannoch on the imperial road; the Capital on the horizon on the road's axis; camera pull-back 12 percent.
- The Undercroft: the colosseum is gone; an abandoned cottage at the end of Champions' Road with a cellar hatch (chained, then glowing with a
  muffled crowd) opens Grand Bellows' booth; texts renamed.
- Verified: `bash tools/run_hub_walk_smoke.sh` (every road blocked and open, in and back, the Capital road, the Undercroft: all ok), GUT,
  town Medium 60.1 fps avg (min 18 on load). Screenshots: `docs/art/hub_world/` + `docs/art/hub_world.md`.

## Block 4: dialogue (done)
- `docs/design/voice_bible.md`: global rules (puns, sprinkled millennial references, 1-3 sentences, sincere beats stay sincere), each Path's
  humour and 2-3 sample lines for every speaking character.
- Rewrite: walls of text split into short boxes everywhere (419 extra boxes); gatekeepers rewritten round their obstacles; town, exits and hub lines
  updated; stale names fixed; new lines for all 12 vendors; quest summaries punched up; tips (quests, gear, hub, per-zone lore); battle-tip winks; a
  mini-story beat per zone (a local who remembers the king and the little prince, and a moment when the zone is freed).
- Old beside new for every changed line: `docs/design/dialogue_rewrite.md` (`node tools/dialogue_diff.js`, 736 rows).
- Fit: every story line fits the box at the default and the largest text size (`tests/test_dialogue_fit.gd`); quest logic reads ids and flags, never
  text (the three story tests that check phrases still pass). 1664 GUT passing.

## Block 5: playthrough bot, hitches (done)
- `bash tools/run_story_playthrough.sh` (`tools/story_playthrough.gd`): new game -> the forest -> the tutorial cave -> town -> Brannoch -> for each
  zone: the gatekeeper (E, the duel on the zone's board, won by decree), the Path Pack, the cleared obstacle, walking down the road into the zone,
  the favour and its midpoint gear, the side dungeon's first clear and its gear, the main dungeon (zone freed, the main line complete, its gear), back
  to Maren for the memory fragment -> the Undercroft hatch and booth -> the imperial road into the Capital with every service restored -> the castle,
  Primm defeated, Free the Four Zones complete -> the ending. **73 steps, 73 passed** (last run). Real input: walking, E at every NPC, the tracker
  keys; decree: battles, a favour's steps, dungeon resolution, the tutorial's rewards (each named in the bot's header).
- What the bot found: a real bug (a handed-in favour did not pay its zone line's midpoint gear until something else changed; quests now settle at
  once when one completes) and two things a bot must answer like a player (level-up equipment-slot choices, the Second Path announcement).
- Load hitches (`HITCH_LOG=1`, `--spikes=true`): the Capital's district music and ambience loaded synchronously on the first walk into each
  district, and its ash pre-simulated 7 s of particles on the first frame. Now they load on background threads as the Capital opens, and the ash
  pre-simulates 2.5 s. Min fps on Medium (5 s window after a 3 s warm-up; this iGPU is noisy, one stray 35-50 ms frame now and then is the driver):

| Area (Medium) | avg fps | min fps |
|---|---:|---:|
| Town (the hub) | 60.4 | 30.3 (one stray frame) |
| Starting forest | 59.7 | 28.5 (one stray frame) |
| The Gainlands | 59.7 | 23.7 (one stray frame) |
| The D.N.A. | 60.1 | 19.1 (one stray frame) |
| The Endless Buffet | 60.0 | 60.0 |
| The Verdant Dump | 59.9 | 55.4 |
| Capital: gate road, camp, rift fields, outpost | 60.0 | 60.0 |
| Capital: gate plaza (hub load) | 60.0 | 60.0 (was 18.5) |
| Capital: Transit Yards | 60.0 | 60.0 (was 31.4) |
| Capital: Hungry Quarter | 59.7 | 55.4 |
| Capital: Grave Row | 60.0 | 60.0 |
| Capital: the Reek | 60.0 | 60.0 (was 14.8) |
| Capital: palace approach | 59.6 | 30.9 (one stray frame) |

## Look at these first
1. `docs/art/hub_world/road_*.jpg` - the five roads (forest path, cracked road, meadow road, orchard lane, imperial road).
2. `docs/art/hub_world/gate_*_locked.jpg` and `_open.jpg` - the four obstacles and their cleared states.
3. `docs/art/hub_world/capital_horizon.jpg` and `undercroft_house.jpg`.
4. `docs/art/hub_world/edge_*.jpg` - the horizon from all nine camera combinations.
5. `_screenshots/quest_smoke/` (tracker, Quest Log, "!" / "?" marks) and `_screenshots/playthrough/` (the bot's journey).

## Decisions I made for you
ON-1..ON-32 in `docs/design/open_questions.md` ("Overnight decisions (Oct 16)"). The big ones: one MAIN quest per zone with step rewards (ON-2);
the favour midpoint (ON-3); old saves never double-dip (ON-5); Brannoch gives the Capital quest (ON-7); `[` / `]` for the tracker (ON-8); the hub's
walkable ground unchanged, roads as scenery past the passages (ON-22); obstacles angled for the north-looking camera (ON-23); the Undercroft where
the colosseum stood (ON-27); the dialogue pass kept what was already good (ON-29).

## Unfinished / honest notes
- The hub graphics pass covered the roads, edges, lakes, obstacles, outskirts buildings, a lake dock and the Undercroft; the graveyard and the chapel
  hill were left as they were.
- The south road's drawn-up bridge cannot be seen from the north-looking camera (only the lowered one reads).
- The obstacles are built from kit textures and painted cards, not concept art (backlog: "Overnight run").
- The dialogue rewrite is a consistency, length and voice pass, not a line-by-line rewrite of all 2,700 lines: much of the existing writing already
  matched the voice bible, and every changed line can be reverted from `docs/design/dialogue_rewrite.md`.
- Min-fps spikes elsewhere are single stray frames (driver/OS), not repeatable hitches; the Capital's were repeatable and are fixed.

## Try this in the morning
1. New game, reach town: the tracker shows Raise the Bar with its checklist; press `]` and `[` to flip quests; press J (Main / Side / Completed).
2. Walk north up the Gate Road to Brannoch ("!" over his head) for Free the Four Zones; look up the imperial road at the Capital on the horizon.
3. Walk south down Champions' Road to Brick Bronson at the gorge; beat him and watch the bridge swing down; your Beefcake Pack arrives.
4. Walk the west roads (forest path, cracked road with dead lamps) and the orchard lane east; the gatekeepers stand at their obstacles.
5. Free a zone, then find the old cottage at the end of Champions' Road: the cellar hatch glows and a crowd roars below.
6. Finish a Gainlands favour: the Gotta-Go Galoshes (Boots) make you walk 35 percent faster; hover gear in a shop or on the character screen.
7. Read `docs/design/dialogue_rewrite.md` and revert any line you don't like; `docs/design/voice_bible.md` is the style guide.
8. Run `bash tools/run_story_playthrough.sh` (about 6 minutes) to watch the whole story played.

## Smokes run tonight
- `bash tools/run_quest_smoke.sh`: OK. `bash tools/run_hub_walk_smoke.sh`: OK. `bash tools/run_story_playthrough.sh`: 73/73 (one earlier run had a
  leftover announcement block a gatekeeper talk; the bot now clears overlays first).
- `bash tools/run_town_slice_smoke.sh`: PASSED (14 spots) after raising its dialogue guard: Bertram's long intro is now split into more,
  shorter boxes and outlasted the old 12-press limit. Older smokes with a short dialogue guard may need the same nudge.
- `bash tools/run_gainlands_walk_smoke.sh`: OK (rerun after everything). `bash tools/run_quest_smoke.sh`: OK (rerun after everything).
- GUT: 1664 tests, all passing.
