# Overnight Oct 17 - loop state

Start: Sat Oct 17 20:52:45 MDT 2026 (end target: Sun Oct 18 07:52 MDT)
Start tag: pre-overnight-oct17

## Current
Phase 2, cycle 12 starting (Sun Oct 18 ~03:05 MDT). Cycles 1-11 committed and pushed; one line each in loop_log.md.

## Done (commits)
- Phase 1: Parts 1-14 committed and pushed (git log "Overnight Oct 17, Part N"), plus the Patchwork rename and small follow-ups.
- Phase 2: cycles 1-11 (git log "Overnight Oct 17, Phase 2 cycle N"); scores in scorecard.md.

## Next
- Keep cycling on the lowest category (scorecard.md / next_up.md) until ~07:30, then write docs/overnight_report.md, tidy the inbox, final commit and push.

## Notes
- tools/gut_one.sh runs single test files; full suite ~7 min (don't edit loaded files mid-run).
- Pre-existing failure: tests/world/test_world_look_rig.gd line 94 (CP-2).
- Bots: tools/run_tour_bot.sh (TOUR_ONLY=town for a quick run; frames are wall-clock since cycle 5), tools/run_story_playthrough.sh (73 steps).
- Smokes: run_first_battles_smoke.sh, run_music_smoke.sh, run_dungeons_final_smoke.sh (one stale check, next_up 11).
