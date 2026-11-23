# Fable, night of Nov 22-23: Batch 19 in the game, the owner's balance answers, the two-week plan

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner approved all 8 pictures of Batch 19 and answered "Fable Nov 21 castle". Work through the night without stopping to ask.

Read first:
- the top of docs/overnight_report.md ("Fable Nov 21 castle") and docs/overnight_inbox.md;
- docs/balance_report_nov21.md (sections 5 to 7);
- docs/release/two_week_plan.md;
- docs/owner_backlog.md;
- docs/art/batch19.csv.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 22 night". Tag `pre-fable-nov22-night`. Work in this order; if time runs short, finish the part you're on, then do Part 6 and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory (the PC froze two nights ago):**
  - ONE Godot process at a time; no sub-agents while Godot runs;
  - `tools/run_tests.sh --min-free=1200`, with the shards in small groups;
  - the story bots one after another, never in parallel;
  - long sims split into runs of about 30 variants, each in a fresh process;
  - the export only after the tests, with `EXPORT_LOW_MEMORY_OK=1` if needed.
  - If the guard stops a background run, finish it in the foreground with `--from=N --to=K`.
- Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov22/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - no new painted art (Batch 20 rows instead, in `docs/art/batch20.csv`);
  - the 45-card minimum stays.
- **Dialogue:** single lines only, with `docs/dialogue/nov22_lines.csv` and `_ids.txt` for `--revert`.
- Every rules, card or item change gets a test.

## Part 1 — Import Batch 19 (8 pictures)
**Source:** `G:/My Drive/Card Game Art/Pending Review/Batch 19/` (all 8 approved; the sheet tab "Batch 19 Nov 22" lists them).
1. **Copy** each into its Approved folder on the Drive (leave the Pending Review copies). Import with the usual tools and compression.
2. **Wire them:**
   - **MAP-PC:** the new Primm's Castle map. Place every room node on its painted landing spot and match every link to a painted walkway. Where the painting misses a walkway or a room, keep the drawn line for that link, and add a Batch 20 redo row naming exactly what's missing. Retire the plain-line overlay where the painting covers it. Shoot the whole map and three routes.
   - **BST-THE-PANTRY-MIMIC:** the Bestiary and the battle portrait (it replaces the Doppelganger echo stand-in).
   - **UI-ALEMBIC-BREW:** the centre of Auntie Alembic's brew panel (it replaces the small cauldron). Keep the bubbles and the flash when brewing.
   - **UI-ALEMBIC-JAR:** the four essence jars. The game draws the tinted liquid behind the glass and the number on it.
     - **Check the jar's inside is really transparent.** If it isn't, cut it out cleanly in code (an alpha mask), or keep the drawn jars and add a redo row.
   - **UI-PACK-LOCKED-N:** the locked Necrocrat parcel in Foil Fenwick's shop, beside the other three.
   - **MAP-WORLD-BUFF:** the Buffet's map. Check The Raw Deal's icon sits on the painted sushi shop in the east district.
   - **T-PC-TRAINEE** and **T-PC-STATUE:** the token art in "Hold the Line" and "Clean Out the Polish" (no more tinted stand-ins).
3. **Check:**
   - shots of each in place;
   - the castle walk-through bot;
   - Alembic's shop at 1280x720 and 1920x1080;
   - the download size before and after.

## Part 2 — The owner's answers (items, Arena, allies, castle, camera)
1. **Items and equipment** (balance report section 5):
   - **Gladiator's Net:** -1/-1 to **the first enemy unit each turn** only (was every unit as it enters).
   - **Clipwell's Golden Shears:** no change (stays 2).
   - **Bloodsand Boots:** no change (it may draw several times a turn).
   - **Siphon's Lens:** max HP **-2** (was +2).
   - **Glass Jaw Gauntlets:** max HP **-6** (was -3).
   - **Dex's Matching Pair:** copies only a card that **costs 3 or less**.
   - **Elastic Waistband of Victory:** no change.
   - **Hover Boots:** your units **can still block units with Flying**.
   - **Velvet Rope:** Gourmand units **+1/+2** (was +0/+3).
   - Card and item text, glossary, tests.
2. **Grand Bellows:** remove "The Crowd Roars" (+1/+1) again and keep 64 HP. Re-simulate that one bout **with his scripted events**, and report the win rate.
3. **Beefcake against Primm:** no change.
4. **Grandmaster Flex, reduced everywhere:** wherever Flex fights as a unit (the castle ally on turn 2, and any other card, token or encounter that puts him on the board), he is a **3/5 without Indestructible**. Then re-run the Primm sim (allies 0-4, each Path) and adjust Primm's numbers only if the totals leave the owner's targets: about 30 % with no allies and about 65 % with all four.
5. **The all-allies route:** add **one "heal 6 for a cost" room in its fourth row** (the same rules as the Garden). Keep the "all four in one run" rule and the "skips most treasure and heals" feel. Re-run the whole-castle route sim (every route); aim for about 35 % on the all-allies route; report every route.
6. **The camera:** the default for new games and for players who never changed it is **+6** (as now). V still cycles the five presets, and the choice is saved. Record it.

## Part 3 — The two-week plan (what Fable can do)
Work down `docs/release/two_week_plan.md` and do the items marked for a Claude Code run that need no owner decision and no new art, in the plan's order. Examples, if still open:
- switch the export to the player read-me (the playtest read-me stays for playtest builds, behind a flag);
- leftover text consistency ("Stock The Pantry" style capitals that aren't from the owner's sheet);
- smokes that went stale;
- small player-facing polish found on the way.

Leave anything marked as the owner's (the Arena hand pass, the itch page, the setx step, the Codex folder), anything needing a decision, and anything bigger than about an hour. Tick each item done in the plan, with the commit.

## Part 4 — The backlog: write it down, don't build it
Make sure `docs/owner_backlog.md` has, and the two-week plan places:
- the Extra Pocket (double item use) to revisit with testing;
- Beefcake against Mortimer and Primm (watch in playtests, no change now);
- more Arena puzzles;
- the collection grind (13 hours for everything: the essence dial);
- the Deck Station search for controllers;
- the optional D.N.A. map repaint.

## Part 5 — A focused playthrough of what changed
Play from a late save:
- the castle gate to Primm by three routes (the all-allies route with its new heal room, the quiet south, the middle with the Safe Room);
- the Pantry Mimic;
- each ally scene;
- Primm with 0 and 4 allies;
- Alembic brewing a card;
- Foil Fenwick's shop;
- the Buffet's map.

Shoot each, check the logs for errors, and fix what's small and safe.

## Part 6 — Tests, build, report
1. All test shards green, in small groups; the walk smokes (every zone); the NPC visibility probe; the fade probe; the quest hand-in probe; the hover-zoom probe; the puzzle solver tests; the four story bots, one after another.
2. **Export 1.0.0 for the playtesters:**
   - after the tests, wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke (with the export's own pack) and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, at the top, under "Fable Nov 22 night":
   - each part done or not, with shots;
   - the 8 pictures and any redo rows;
   - the item changes;
   - Bellows' new win rate;
   - Primm's table after the Flex change;
   - the whole-castle route table with the new heal room;
   - the two-week plan items done;
   - the download size;
   - the zip's path and size;
   - the dialogue revert command (if any lines changed);
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.
