# Overnight Oct 18 - loop state

Start: Sun Oct 18 18:28:10 MDT 2026 (end target: Mon Oct 19 06:28 MDT)
Start tag: pre-overnight-oct18 (pushed)

## Current
Part 2 (Rebalance G): iteration 1 full sim done (g_iter1.md), iteration-1 edits applied (uncommitted: dungeon_content.json, corrupted_npcs, ninja_boss, gainlands/buffet/capital enemies, primm_boss, arena_defs); iteration 2 sim on changed groups running (_logs/g_iter2.txt, scratchpad iter.sh). Part 8 left: purple shapes look, inbox.

## Done (commits)
- Part 1: dea1e329
- Part 5: 60613118 (done early, docs only)
- Part 3: 29e84c95; Part 4: 12ee6d33; Part 6: cd840871; Part 7: a2f0ed0d
- Part 8 code (uncommitted): tests/world/test_world_look_rig.gd pins camera angle/zoom (user settings.cfg zoom=2.0 broke it)

## Next
- Part 1 -> Part 8, then Phase 2 cycles until 06:28.

## Notes
- Resume: re-read this file, docs/design/balance_state.md, docs/overnight/next_up.md.
- tools/gut_one.sh runs single test files; full suite ~7 min (don't edit loaded files mid-run).
- Pre-existing failure: tests/world/test_world_look_rig.gd (Part 8 fixes it).
- Sim: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --mode=quick --filter=<group> --games=N --out=res://docs/design/sim/x.md`; one group per foreground call, under 10 min.
