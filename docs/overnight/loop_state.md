# Overnight Oct 18 - loop state

Start: Sun Oct 18 18:28:10 MDT 2026 (end target: Mon Oct 19 06:28 MDT)
Start tag: pre-overnight-oct18 (pushed)

## Current
Phase 2 (from 22:20). Scorecard/loop_log/next_up for tonight in docs/overnight/ (last night archived in docs/overnight/oct17/). Cycle 1: Performance (save hitch).

## Done (commits)
- Part 1: dea1e329
- Part 5: 60613118 (done early, docs only)
- Part 3: 29e84c95; Part 4: 12ee6d33; Part 6: cd840871; Part 7: a2f0ed0d
- Part 2: ad4c98cb; Part 8: 3744aa79. Phase 1 complete 22:07.
- Phase 2 start evidence: story bot 73/73, tour bot 275 spots / 0 errors (town 82 frames > 33 ms).

## Next
- Part 1 -> Part 8, then Phase 2 cycles until 06:28.

## Notes
- Resume: re-read this file, docs/design/balance_state.md, docs/overnight/next_up.md.
- tools/gut_one.sh runs single test files; full suite ~7 min (don't edit loaded files mid-run).
- Pre-existing failure: tests/world/test_world_look_rig.gd (Part 8 fixes it).
- Sim: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --mode=quick --filter=<group> --games=N --out=res://docs/design/sim/x.md`; one group per foreground call, under 10 min.
