# Overnight report (Oct 16-17)

Brief: quest overhaul, 25 equipment pieces, the hub world and the Undercroft, the dialogue rewrite, a playthrough bot. Rules: commit + push per part,
STOP_OVERNIGHT file stops the run, `docs/overnight_inbox.md` is read before each part, one Godot at a time. Start tag: `pre-overnight-oct16`.
Decisions: `docs/design/open_questions.md` "Overnight decisions (Oct 16)" (ON-*). The previous overnight report moved to `docs/overnight_report_oct13.md`.

## Status

| Block | State |
|---|---|
| 1 Quest system overhaul | done (see below) |
| 2 Equipment and loot | done (see below) |
| 3 Hub world and the Undercroft | next |
| 4 Dialogue rewrite | - |
| 5 Playthrough bot, hitches, report | - |

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

## Problems / notes

## Next
Block 3: the hub world (land routes, obstacles, smooth edges, Capital horizon, the Undercroft, graphics pass).
