# Overnight Oct 19-20 - loop log (Phase 2)

Phase 2 started Mon Oct 19 ~23:30 (Parts 1-7 done; scorecard re-scored with "Dialogue & story").

## Cycle 1 - Audio mix (lowest, 7.5): loop seams left by Part 7 - no change
- `node tools/music_fix.js --fix MUS-SHOP-GRISTLE MUS-QUIZ MUS-DECK --dry`: the last-50 ms -> first-50 ms seams are within 1 dB (-1.0 /
  -0.5 / -0.2 dB); the 1 s "jumps" (7.2 / 6.1 / 7.7 dB) are the music's own dynamics, and the seam search found no earlier point that is
  better (best correlations 0.07 / 0.65 at +1.8 dB / 0.23), so the composed wraps were kept. MUS-DECK and MUS-QUIZ need new takes (prompts in
  docs/audio/music_generation_prompts.md). Score unchanged (7.5).

## Cycle 2 - Dialogue & story (8): gatekeepers after their zone is freed
- New keys `gate.<zone>.freed` (Brick, Prudence, Fennel, Moss - three boxes each, in voice, each ending on the friendly rematch the game
  already offers), `StoryText.npc_freed_lines` (falls back to the victory lines), `TownScene._talk_corrupted_npc` uses them once
  `Session.is_zone_completed(zone)`. Old keys untouched. Test `tests/core/data/test_gatekeeper_freed_lines.gd`.
- Found while verifying: the Crosspath walk smoke had been failing since the v0.4.0 town roamers (a roamer near (50, -17.8) starts a battle
  mid-loop and the town is freed). The smoke now removes the roamers after the town loads and logs any scene change; OK (18 shots).
- Checks: gatekeeper/dialogue/compile tests 16/16; Crosspath, Capital, Gainlands walk smokes, playtest, prologue smokes and the story bot
  (73/73) OK after Parts 5-6.
