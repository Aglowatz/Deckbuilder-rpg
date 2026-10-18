# Overnight Oct 17 - loop state

Start: Sat Oct 17 20:52:45 MDT 2026 (end target: Sun Oct 18 07:52 MDT)
Start tag: pre-overnight-oct17

## Current part
Part 5 (armory quest + equipment rarity) - code done, full GUT running; Part 4 (deck station) also uncommitted in the tree.

## Done
- Part 1 copy caps (b1422990), Part 2 vendor categories (89a5f3d5), Part 3 chest sparkle (07bf48d7)

## Next
- Commit Part 4 then Part 5 (split game_session.gd/progression_table.gd/test_progression.gd hunks with scratchpad hunks.js: P4 = slot/deck_capacity/DeckSlots, P5 = armory/EQUIPMENT_CHOICE)
- Part 6 level track (data/progression/level_track.json already has copy_caps + equip_caps sections)

## Notes
- tools/gut_one.sh runs single test files (-gconfig= so .gutconfig dirs are ignored)
- Pre-existing failure: tests/world/test_world_look_rig.gd line 94 (CP-2, saved camera FOV)
