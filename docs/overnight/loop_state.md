# Overnight Oct 17 - loop state

Start: Sat Oct 17 20:52:45 MDT 2026 (end target: Sun Oct 18 07:52 MDT)
Start tag: pre-overnight-oct17

## Current part
Part 13 (UI consistency + bot) - UI edits applied (UiInput, OverlayScreen focus/fade, focus ring theme, ConfirmDialog/PopupFrame), tour bot re-running.
Part 14 (ambient fx) - world/ambient_fx.gd written; scene hooks saved in scratchpad p14.patch (re-apply with git apply after the bot run).

## Done (commits)
Parts 1-12 committed and pushed (see git log "Overnight Oct 17, Part N"), plus the Patchwork rename and small follow-ups.

## Next
- Commit Part 13 after GUT; apply p14.patch, test, fps check, commit Part 14.
- Phase 2: docs/overnight/scorecard.md, next_up.md, loop_log.md; cycles of ~45-60 min.

## Notes
- tools/gut_one.sh runs single test files; full suite ~7 min (run in background, don't edit loaded files mid-run).
- Pre-existing failure: tests/world/test_world_look_rig.gd line 94 (CP-2).
- Bot: bash tools/run_tour_bot.sh (9 min) -> docs/overnight/bot_report.md.
