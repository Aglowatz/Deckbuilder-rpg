# Fix pass — Nov 8 (Opus) — owner decisions on the overnight, leftovers

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Read docs/overnight_report.md (Overnight Nov 7-8) first. Work
autonomously; log questions in docs/overnight_inbox.md under "Fixes Nov 8".

House rules:
- STOP_OVERNIGHT check before each part.
- ONE Godot at a time; kill stray Godot processes first.
- At most 2 sub-agents, never while Godot or tests run.
- Memory-safe test shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N` to resume).
- Screenshots go to docs/overnight_shots/nov8b/.
- Commit and push after each part. No export.

## Part 0 — Finish last night
1. Run the full test shards and fix any failures.
2. Run the Primm no-grind-deck measurement (`Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --games=16 --filter=D-PC:10 --budget`) and add the result to docs/balance/primm_explained.md as Measurement 2.

## Part 1 — Owner decisions
1. **Gatekeepers can be fought right away, at any time.** Last night built the old version ("come back when Maren sends you"), so remove that block.
   - The player just isn't directed to them (no quest, tracker line or map pin) until Maren's questline is done.
   - Beating one early counts: its quest shows as complete when Maren gives it.
   - Add a test.
2. **Rename the matching-quest boots** from "Dex's Lucky Spats" to **"Dex's Matching Pair"**.
   - The approved wording stays: "Once each turn, when you play your first non-Infrastructure card, draw a copy of that card from your deck (if there is one)."
   - Rename the icon id to ICON-EQ-MATCHING-PAIR in data, the art list and the importer rules.
3. **Difficulty: no changes** to Clench, the Automaton or the Gallery. The owner wants these to push players toward different decks and multi-Path cards.
   - Revert only if last night changed any of them beyond the approved list.
   - Log the current win rates in the report.
4. **Primm:**
   - Clear explanations, no number changes, no healing between phases.
   - Before phase 1 the rules card says plainly: "Every unit is a 3/3, so cheap units are as good as big ones. You may play two cards a turn."
   - Give phases 2 and 3 the same plain one-line explanations.
   - The Deck Station offers "Primm deck" advice (more cheap units) when the castle is next.
5. **Economy — restore no-grind income to about 21,200 gold** with the new prices (Commons 50 / 100 / 250 / 500, gear from 250).
   - Goal: players can collect **three copies of every card** and then **craft all the multi-Path cards**.
   - Scale the gold sources back up (quests, clear bonus, nodes, late fights) to about 21.2k for a no-grind run, keeping the intro checkpoint: after the equipment quest, 1 gear piece + 4 Commons + 2 items is affordable.
   - Re-run the gold study, then report:
     - how much of "3x every card + every multi-Path craft" a no-grind run reaches;
     - the extra grinding (in fights / hours) to finish it. Target: finishing everything takes a moderate amount of extra play, not a slog.
   - Check crafting costs (essence and gold) against that goal and adjust them if they are the bottleneck.
6. **Dex Shufflewick gets his own art** (portrait NPC-DEX, sprite set SPR-DEX: REF, FRONT/SIDE/BACK idle, FRONT_TALK). It's coming in Batch 13.
   - Add the rows to docs/art/art_needed_nov4.csv.
   - Wire the ids so the import swaps out the generic townsfolk stand-in.

## Part 2 — Leftovers from the overnight
1. **The Capital's load time:** profile it (numbers before and after), bake the painted swaps at import, and prewarm materials behind the fade.
2. **The Dump's 15-17 s first load** and the first-visit shader hitches.
3. **The holes in the Gainlands cliffs** (and check Low-end for them).
4. The "after" screenshots of the new Wardrobe and Card Packs pages.
5. The rest of the Nov 7 quick wins (inbox "Fixes Nov 7", item 12).

## Finish
- Run all test shards green.
- Write docs/overnight_report.md with the gold study table, the collection-completion estimate, the Primm Measurement 2, the load-time numbers and screenshots.
- Commit and push. No export.
