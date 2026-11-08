# Import Batch 13 + polish — Nov 8 (Opus)

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Work autonomously; log questions in docs/overnight_inbox.md under
"Import Nov 8".

House rules:
- STOP_OVERNIGHT check before each part.
- ONE Godot at a time; kill stray Godot processes first.
- At most 2 sub-agents, never while Godot or tests run.
- Memory-safe test shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N` to resume).
- Screenshots go to docs/overnight_shots/nov8c/.
- Commit after each part; push when GitHub is reachable (retry the push at the end of each part). No export.

## Part 0 — Finish the last pass
- Run the remaining test shards from 9 (`--from=9`) and fix any failures.
- Push the unpushed commits.

## Part 1 — Import Batch 13 (23 approved images)
The source is `G:/My Drive/Card Game Art/Pending Review/Batch 13/`.
- Move each file into its Approved_* folder per the art list (docs/art/art_needed_nov4.csv). Old versions go to Superseded.
- Run the importers one Godot at a time, then mark the rows "In game" in the art list.

Wire and check each one in game, with a screenshot:
1. **BB-S-GALLERY**: the battle board for every Shattered Gallery fight. Keep **BB-S-GALLERY-ALT** too, and use it for the final room (The Perfect Copy), so the boss fight looks different.
2. **DEC-PLINTH-BEEF / NECRO / GOUR / REF**: the statues on Crosspath's fountain plinths, one appearing per freed zone (C4 F10). Scale them to the plinths and check them from the default and Low camera.
3. **UI-CAULDRON**: replaces the flat vector cauldron on Auntie Alembic's craft screen.
4. **UI-BG-PACKS** + **UI-PACK-SHELF**: the redesigned Card Packs page and the pack result screens.
   - The shelf image is 1536x1024 with the board across the middle: crop it to the board and fit it to the shelf panel (it must not sit on the pack names).
5. **UI-BG-WARDROBE**: the redesigned Wardrobe's background, replacing the dimmed Character-page crop.
6. **KIT-HEAP-THORNWALL / -DEAD**: the breathing thorn wall across the path at Moss Mulligan's gate.
   - Add a gentle "breathing" scale pulse in code. It swaps to the withered, parted state once Moss is beaten.
   - Make the collision match the art (closed before, open after).
7. **LEVER-LOCKED / LEVER-OPEN**: replace the code box on all five levers (four zone vaults and Crosspath's old lever by the Secluded Grove).
   - Keep the Path tint on the plinth badge.
   - Swap to the open state when pulled, with a short animation (a code tween or a quick cross-fade).
8. **ICON-EQ-MATCHING-PAIR**: the icon for Dex's Matching Pair everywhere it shows (Character page, shop tooltip, quest reward).
9. **MG-BG-CLASSROOM**: the trivia background for every zone's quiz.
   - The zone's quiz-giver stands in the open left third as the teacher (their portrait), and the question is drawn on the blank chalkboard.
   - Remove the coded stand-in.
10. **MG-BG-GYM**: the backdrop for the Gainlands' Rep Counter minigame.
11. **NPC-DEX + SPR-DEX** (REF, FRONT/SIDE/BACK idle, FRONT_TALK): Dex Shufflewick's own portrait and sprite at his table in every Path zone, replacing the generic townsfolk stand-in. Check his scale against the hero.

Check the import's memory and size cost against docs/build_size_policy.md and report it.

## Part 2 — Quick wins still open
From docs/review/critic_nov6_summary.md section 3 and the last report:
- the forest station showing "???" (reproduce it, then fix);
- the Dump's overworld haze (cut the colour grade and edge blur by about a third);
- the quest log control hint under the quill art;
- tips that overflow and cover content;
- the wrong name tag (Old Hob over Granny Gristle's prompt);
- the zone banner (held until no dialogue is open; skipped after a defeat);
- the sticky tooltip, the "Rules of this fight" drawn twice, the round label lag, the ENEMY TURN banner over the action line.

## Part 3 — Capital later-visit load (about 7 s)
Do the next step the last pass named: cache the Capital's other buildings (and anything else rebuilt on every visit) in the saved build data. Report before and after for first and later visits.

## Part 4 — Fresh-eyes check
One fresh critic (no context) plays a new save for 60 minutes from the title, then visits by snapshot:
- the Gallery;
- a trivia game;
- Dex's matching game;
- the Wardrobe;
- the Card Packs page;
- Alembic's cauldron;
- the Dump gate.

It scores the first hour, flags anything that looks out of place in the new art, and lists its top 10 issues. Fix the quick ones; log the rest.

## Finish
- Run all test shards green.
- Write docs/overnight_report.md with a per-image import table (screenshot, scale check, memory/size cost), the quick wins, the load numbers and the critic's top 10.
- Commit and push. No export.
