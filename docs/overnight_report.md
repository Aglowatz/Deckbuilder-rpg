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
| 5 Playthrough bot, hitches, report | next |

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

## Problems / notes

## Next
Block 5: the playthrough bot, load hitches, final report.
