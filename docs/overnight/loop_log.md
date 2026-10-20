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

## Cycle 6 - UI consistency (8.5): the old character background's spare leader lines - tried, reverted
- Covered the three painted leader lines of the spare frames with parchment-coloured strokes (Line2D, colour sampled beside each line).
  The strokes did not sit exactly on the painted lines and read as light smudges (`_screenshots/oct19n_c6_character_lines.png`), so the
  change was reverted. The real fix is tomorrow's UI-BG-CHARACTER without painted slots (the layout switches to our own frames by itself).

## Cycle 7 - NPC life & dialogue: the rest of the long first talks
- Basil 11 -> 5 (freed 8 -> 5), Tarragon 10 -> 5, Foreman Gus 9 -> 5, Old Man Mountain 9 -> 5 (freed 8 -> 5), Benchley 7 -> 5, Widow Pell
  6 -> 5, Chef Marlo 6 -> 5; quiz facts, quest steps and every callback phrase kept. No first talk in the game runs over 5 boxes now.
  Dialogue tests 71/71. NPC life & dialogue 8.5 -> 9.

## Cycle 8 - Onboarding (8.5): the cave run on a third seed - measured, no change
- 100 runs per Path at seed 9200: B 92 / G 84 / R 84 / N 90 (matches 7000/8100 within noise). Gourmand and Refusemancer at the target's
  bottom edge; logged in balance_log.md. Onboarding stays 8.5 (first talks shorter, opening rewritten, cave confirmed on three seeds).

## Cycle 9 - bots + Dialogue & story: freed-zone barks
- Bots (cycles 5-8 done): story bot 73/73.
- `ZoneStoryText.get_lines` already prefers `<key>.freed` once the zone is freed, so new keys alone fix stale lines: the Dump's three
  terrace workers (`bark.worker_1..3.freed`: green trees, flowers that smell like flowers, the Archdruid on her rounds) and the D.N.A.'s Kyle
  (`npc.matching.return.freed`) and Director Ectomund (`npc.quiz.return.freed`). Dialogue tests OK. Dialogue & story 8 -> 8.5.

## Cycle 10 - Audio mix (7.5): the Old Well's music
- The Echo duel played the generic town battle song; it now plays MUS-VAULT-BATTLE (the Forgotten Vault is built over the spring; the
  vault's boss song stays the Guardian's). The well's two visions (the start and the final reveal) play MUS-VAULT-EXP over the town track
  (push/pop), and STG-SECRET rings when the quest begins. Test in `tests/audio/test_music_playback.gd`. Audio 7.5 -> 7.5 (needs ears).

## Cycle 11 - Stability (8.5): the Old Well in the live game + a full GUT run
- New windowed smoke `bash tools/run_old_well_smoke.sh` (written by a helper, run here): first touch -> vision -> quest active (SIDE,
  no markers, hero unlocked) -> the Dump and Buffet hums in their zones (spot, glow, find, flag, spot gone) -> READY -> "Lean over the Old
  Well" -> confirm -> brief with The Spring Remembers + icons -> duel (enemy, rule badges, HUD icons, MUS-VAULT-BATTLE) -> forced win ->
  final vision -> quest completed, Phial owned once, stage DONE, hero free. **OK, every check passed.** Shots `_screenshots/old_well_0*.png`.
- GUT 1997/1997 in three foreground batches (core 1273, world 371, rest 353). Stability 8.5 -> 9.

## Cycle 12 - NPC life & dialogue: the rewrite seen in the real dialogue box + fps after the overhead rule
- `tools/dialogue_shots.sh` on Elder Maren (Crosspath), Basil (Buffet), Agnes (D.N.A.): the new first lines sit in two box lines with the
  portraits; Agnes's frame also shows the new D.N.A. interior from the play camera. Shots `_screenshots/dialogue/oct19n_dlg_*.png`.
- fps on Medium after the OcclusionFader's overhead rule: Buffet 59.7, Dump 59.8, Crosspath 60 (avg).

## Cycle 13 - Dialogue & story: the 102 NPC barks
- Every passing bark rewritten to the voice bible by a helper and self-scored: 3.12 -> 4.00 (min of five per NPC; all >= 4). Fixed bark
  contradictions (Primm "sweeping the square" while he is under guard, Agnes as a librarian, a dragon cousin, Moss's "Everything rots"),
  gatekeeper barks true before and after their zone is freed, seven barks that copied story text. `sample_line` = barks[0] kept in sync,
  `tools/npc_truth_input.json` too (a re-run of the tool keeps them). Fig Sly untouched. NPC tests 23/23.
- Part 1 coverage note: the nine grid cameras are exactly the V (Cinematic / Classic / Overview) x F (1.2 / 1.5 / 1.9) presets.

## Cycle 14 - Visuals (8.5): the D.N.A. walk frames re-checked after Part 1
- Looked at the walk smoke's breakroom frames (`w_05_gerald`, `w_06_coffee`): the hero seemed missing; shots at the smoke's exact positions
  ((26, 52), (23, 52)) and at the Cinematic camera show the hero visible - in the smoke's camera the hero stands right in front of Gerald /
  the coffee urn and the sprites overlap. Not a bug.
- Found on the way: the per-piece fade only fully fades a wall piece whose centre is >= 0.9 m in front of the hero along the sight line, so
  a hero pressed against a 4.5 m wall was only ~1/3 faded. The ramp is now 0.45 -> 0.05 m (`dna_fade.gdshader`). Walk smoke OK; D.N.A.
  tests OK; shots `_screenshots/oct19n_c14_*.png`.

## Cycle 15 - Combat feel (8.5): the token's tip box repeated its text
- A Contract token showed its ability text and then the same text again as its glossary entry. A glossary entry identical to the card's
  ability text is skipped now (`BattleHud.show_preview`). Shot `_screenshots/oct19n/p2_after_token_0.png` (re-taken). Tip tests OK.

## Cycle 16 - Collection (8): a Gear tab in the Collection Book
- Third tab "Gear" (helper-built, checked here): all 55 pieces once (`GearCatalog.all_pieces` merges the vendor and zone equipment),
  grouped Helm / Weapon / Armor / Boots / Relic with "x / y found", an owned piece shows its icon (tomorrow's ICON-GEAR art shows here),
  name, rarity and effect; a missing piece is a silhouette with where it comes from (vendor, quest, dungeon first clear, puzzle, arena
  prize); secret pieces (the Old Well's Phial, the vault and the Lab relics) say only "A secret". Built on first open (like the Bestiary).
  Fixed on review: the arena hint used the retired name "Grand Clashatorium" -> "The Undercroft". Tests 16/16 (gear tab, catalog,
  collection book, compile). Shot `_screenshots/oct19n_c16_codex_gear.png`. Collection 8 -> 8.5.

## Cycle 17 - bots + Balance look: why a L5 Necrocrat loses to the Gainlands roamers
- Bots (cycles 13-16 done): tour bot OK (275 spots, 0 errors); story bot 73/73.
- Replays (`replay_encounter --id=zone:beefcake:brute --path=necrocrat --games=20`, 8/20 won): in the lost games the sim's L5 Necrocrat
  reference deck (19 basics of 46 cards) plays only infrastructure for four turns and its first unit lands on turn 8-10. The low number is
  the sim's reference deck as much as the roamers; no game change (logged for the user with the rivalry question).

## Cycle 18 - Onboarding (8.5): the opening's reading time
- The onboarding bot showed tonight's rewritten opening read slower (10.9 min vs 10.6 this morning). The three opening segments were
  tightened ~20% of their words (beats, callbacks, jokes and instructions kept; boxes merged): wake-up -> Path choice 77.6 -> 62.0 s
  (17 -> 12 boxes), after the choice 31.6 -> 26.6 s, Maren's welcome 47.9 -> 36.9 s. **New Game -> first saved deck edit: ~10.3 min,
  89 clicks/keys, 23 dialogue lines** (morning: 10.6 min, 97, 31). Prologue + playtest smokes OK; story tests 24/24. Onboarding 8.5 -> 9.

## Cycle 19 - Stability (9): smoke sweep
- OK: boss rules smoke, release smoke (PASSED), hub walk smoke (five roads + the Undercroft, 18 shots). Earlier tonight: playtest,
  prologue, first-battles, story bot, tour bot, D.N.A. / Buffet / Dump / Gainlands / Capital / Crosspath walk smokes, Old Well smoke.
- Stale (not tonight's regressions, logged for the user): `run_final_flow_smoke.sh` (still looks for the forest's hidden tunnel, removed by
  the Oct 18 Opening Forest rebuild) and `run_fourth_brief_final_smoke.sh` (reads `LevelUpScreen._child_screen`, gone since the Oct 17
  LevelUpScreen rewrite). The old per-brief smokes are superseded by the playtest / release / walk smokes listed in CLAUDE.md.

## Cycle 20 - Dialogue & story (9): storming the castle early
- The Capital is open from the start, so a hero can reach Primm with fewer than four zones freed - and then quoted the four leaders'
  lessons he had never heard. `CutsceneDefs.beats(scene_id, rushed)` swaps the three lesson lines (`RUSHED_KEYS`) for `.rushed` variants
  in the Wanderer's own words when `Session.completed_zone_count() < 4`; with all four freed nothing changes. Test
  `tests/core/dungeon/test_primm_rushed_lines.gd`; finale + fit tests OK.
