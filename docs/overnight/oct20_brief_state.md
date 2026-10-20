# Oct 20 brief: Dev Menu + early-game quest flow (resume file)

Brief: Dev Menu (P1), the Rescuer's opening (P2), NPC label radius (P3), early-game main quest chain (P4), spoiler-free one-step-at-a-time
quest objectives (P5), verify (P6). Check for `STOP_TASK` (repo root or `C:\Users\asche`) before each part. Per part: GUT (three foreground
batches: tests/core, tests/world, the rest), walkability + relevant smoke, commit, push. One Godot at a time. Screenshots 1280x720 in
`_screenshots/oct20d/` (git-ignored).

## Done
- P2 `f5526ffd`: `prologue.rescuer.1..4`, `prologue.wanderer.1/.3`, one self-talk line (intro_story.tres); bible section 7;
  `tests/test_prologue_rescuer_text.gd`. Prologue smoke OK.
- P3 `440ee694`: `NpcLabels.NEAR` 6.0 / `FADE` 1.0 on ground distance for every label (always/boosted only change size/colour).

## Next
- P1 Dev Menu (F10, debug only via `DevTools`), P4 chain, P5 objective reveal + text, P6 smokes.
