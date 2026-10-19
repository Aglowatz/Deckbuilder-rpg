# Overnight Oct 18 - loop state

Start: Sun Oct 18 18:28:10 MDT 2026 (end target: Mon Oct 19 06:28 MDT)
Start tag: pre-overnight-oct18 (pushed)

## Current
Part 1 (Rebalance F: equipment + items) - starting.

## Done (commits)
- (none yet)

## Next
- Part 1 -> Part 8, then Phase 2 cycles until 06:28.

## Notes
- Resume: re-read this file, docs/design/balance_state.md, docs/overnight/next_up.md.
- tools/gut_one.sh runs single test files; full suite ~7 min (don't edit loaded files mid-run).
- Pre-existing failure: tests/world/test_world_look_rig.gd (Part 8 fixes it).
- Sim: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --mode=quick --filter=<group> --games=N --out=res://docs/design/sim/x.md`; one group per foreground call, under 10 min.
