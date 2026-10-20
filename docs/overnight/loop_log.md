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

## Cycle 3 - Balance (8): Primm's three phases with the boons - measured, no change
- 12 runs per Path in one HP pool with the four leaders' boons: Beefcake 50%, Gourmand 58%, Refusemancer 42%, Necrocrat 83% (~58% mean;
  without boons 4-21%). In band; logged in balance_log.md; answers Daytime inbox item 1. Balance 8 -> 8.5 (the last unmeasured boss is measured).

## Cycle 4 - Collection (8): the Wellspring's Echo in the Bestiary
- `data/bestiary/bestiary.json` entry (boss, "The Old Well, Crosspath", icon lorc/drop, blurb in the Bestiary's voice); image request
  `BST-THE-WELLSPRING-S-ECHO` added by `node tools/bestiary_requests.js` (91 requests). Bestiary + Old Well tests 32/32. Collection 8 -> 8
  (one more entry; the pictures arrive with tomorrow's import).

## Cycle 5 - NPC life & dialogue (8.5) + the 4-cycle bot check
- Bots first (every 4 cycles): tour bot OK (275 spots, 9 menus, 5 battles, 0 errors, 0 warnings); story bot 73/73 earlier tonight.
- First-hour visibility check at Gatekeeper Brannoch (the playthrough frame looked like the hero was missing): the OcclusionFader works there
  (OCCLUSION_OFF A/B: the house in front is removed); the hero stands right in front of Brannoch and a lamp post + the [E] prompt overlap
  in that frame. Cosmetic; no change.
- First talks (intro + quest offer joined by `ZoneScene._talk_quest_npc`) trimmed to <= 5 boxes: Agnes 8 -> 5, Gerald 7 -> 4, Ledgerbone
  7 -> 5, Bramble 8 -> 5, Wren Muckfoot 7 -> 5, Granny Gristle 7 -> 5, Chet 8 -> 5, Flambe 9 -> 5, Capital Wren 4 -> 3 (+ insights); quiz
  facts, quest instructions and callback phrases kept (docs/design/dialogue_pass_oct19.md "First-talk trim"). Dialogue tests 109/109.
