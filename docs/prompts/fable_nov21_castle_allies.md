# Fable, Nov 21 evening and night: Primm's Castle rebuilt, the four allies, Primm rebalanced, the owner's playtest list

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the game today; this is his list and his decisions. It's a long run: work through the night without stopping to ask.

Read first:
- the top of docs/overnight_report.md ("Fable Nov 21 review") and docs/overnight_inbox.md;
- docs/balance_report_nov21.md;
- docs/release/two_week_plan.md;
- docs/owner_backlog.md;
- docs/writing/story_bible_v2.md.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 21 castle". Tag `pre-fable-nov21-castle`. Work in this order; if time runs short, finish the part you're on, then do Part 10 and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. **If the Godot editor is open and holds the memory, say so in the report and run what fits** (it stopped the last run's Part 9).
- Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov21c/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - no new painted art (needs become rows in `docs/art/batch19.csv`, each self-contained, under 600 characters, with refs);
  - the 45-card minimum stays.
- **This run may change Primm's Castle (map, rooms, fights) and Primm's fight:** the owner asked for it.
- **Dialogue:** new lines for the allies, the Pantry Mimic and the freed-zone lines, plus the renames, with `docs/dialogue/nov21c_lines.csv` and `_ids.txt` for `--revert`.
- Every rules, card or quest change gets a test.

## Part 1 — Quick fixes and card changes
1. **Choice prompts on top:** when a card asks the player to choose (Millstone Pusher's ability and every other card or effect with options or targets), the prompt text and its option buttons appear **above** the played cards, readable and clickable, never underneath them ("Never mind" too). Check every choice prompt in the game (search the code for them); shoot five.
2. **Wobble Weights:** the Beefcake bonus becomes **+1/+1**, the Necrocrat bonus **+3/+3**, and it **costs 2 to equip**. Card text, glossary, tests.
3. **Crown of Mild Hubris:** add the drawback **-10 max HP** while equipped.
4. **The equipment that makes the opponent discard 2:** discard **1** instead.
5. **The item that summons three 1/1s:** summons **two**.
6. **The double-item-use equipment stays for now;** add it to the backlog to revisit with testing.
7. **Deck builder:** add **Infrastructure** to the card type selector. **A newly created deck becomes the equipped deck automatically.**
8. **Pathwork, not Patchwork:** the kingdom is **Pathwork** (Primm is "the protector of Pathwork"). Change every player-facing use (dialogue, story text, menus, glossary, credits, tutorial, the itch page draft and release drafts, the story bible) from Patchwork to Pathwork. Keep save ids safe. Grep afterwards and list anything left on purpose.
9. **The Mirror Knight's reflections** use the Mirror Knight's own art (with a soft silver, glassy tint), not another unit's picture.
10. **Max-HP curses hit harder, scaled by depth:** about -2 to -3 early in a zone dungeon, -4 to -5 deep in it, **-6 to -8 in Primm's Castle and the postgame**. Update every max-HP-loss drawback and curse; update the choice-node table.

## Part 2 — Primm's Castle: a new map with many routes (the main job)
**Today** the castle is one path down the middle with side rooms. The Courtyard of Perfect Hedges even offers the Hall of Mirrors, which doesn't follow the painted map.

**The owner wants many routes:** some side rooms, but mostly several paths, so **a player can't visit every room in one run**. Part of the fun and the challenge is working out the best route:
- which rooms give bonuses for the boss fight;
- which give good treasure but are optional;
- where the heals are;
- where the allies are.

**Build:**
1. **A layered map** (like Slay the Spire): about 18 rooms in about 6 rows from the Castle Gate to the Model Room (Primm). About three routes that **cross** each other, every connection going forward. A run visits about 8 rooms. Use the existing rooms where they fit (keep their names and their fights where they work) and add new ones as needed.
2. **The room types in each row offer a real choice:**
   - fights (some hard, with better rewards);
   - **treasure rooms** off the main routes (taking one costs another room);
   - **heal rooms, rare** (about 2 on any route; the Resistance Safe Room stays the full heal; others are "heal for a cost" like the zone dungeons);
   - choice rooms (with drawbacks, as everywhere);
   - **the four ally rooms** (Part 3);
   - **the Gilded Pantry** (Part 4).
3. **All four ally rooms can be reached in one run** (owner's decision), but only by a route that skips most treasure and heals.
4. **Rooms that give bonuses for Primm's fight:** keep some, but **not many** (owner's decision): the small permanent stat boons that pile up today (about ten in his last run) are mostly cut. The allies are the main way to prepare.
5. Every connection follows the map; there are no impossible jumps (write a test that checks every exit against the layout).
6. **The painted map:**
   - render a clean **top-down plan** of the new layout (rooms, paths, the gate, the Model Room) to `G:/My Drive/Card Game Art/Batch 19 Refs/plan-primm-castle.jpg`;
   - add a **Batch 19 row** to repaint the castle map from it, in the style of the current castle map (`now_MAP-PC.jpg`, copied there under 1 MB);
   - until it's painted, draw the new layout over the current painting cleanly enough to play (nodes on painted rooms where they fit, simple path lines elsewhere).
7. Shoot the new map and three different routes.

## Part 3 — The four allies (the zone leaders)
Each freed zone's leader waits in an **ally room** in the castle. There the player helps them reach a story objective in a **moderately hard fight**. After winning, there's a short scene with dialogue, and the leader says they'll help against Primm.
- **If that zone is not freed,** the room holds the same fight with no leader, no dialogue and no help (a fair reward instead).
- The old passive leader boons in Primm's rule list ("Grandmaster Flex's Heart", "The Grand Chef's Feast", "Agnes's Appeal" and the Dump's) are replaced by this.

| Leader | The objective in the castle (make each a fight with a twist, from existing mechanics) | The help against Primm |
|---|---|---|
| **Grandmaster Flex** (Gainlands) | Hold the line: keep his captured trainees (allied units) alive for 5 turns | **He joins the fight:** a strong lion unit on the player's side from turn 2 (stats tuned in Part 6) |
| **The Grand Chef** (Buffet) | Win back her stolen recipe (this is in the Gilded Pantry, Part 4) | **Draw 1 extra card each turn** |
| **Agnes** (D.N.A.) | Get her appeal through: survive the red tape and win within a set number of turns | **Your non-unit cards cost 1 less generic energy** (owner's decision) |
| **The Dump's leader** | Clean out the polish: destroy 3 "Spotless" structures | **All your units get +1/+1** |

- Write the four scenes in each leader's voice (the story bible and the registry), with emotional weight and some humour.
- Show the earned help clearly in Primm's fight (in the run-effects line, Part 5) and in the castle map's room tooltips.
- Batch 19 rows only if a scene truly needs new art (for example a portrait expression); reuse existing art first.

## Part 4 — The Gilded Pantry: an optional Gourmand fight
Today it's a purely good room with no reason to visit. Make it an **optional battle** against **the Pantry Mimic**, a Gourmand mimic that copies the cards you play (ties to the Doppelganger story). Beating it gives **good rewards**: a gilded pack plus a choice of one strong boon for Primm's fight. When the Buffet is freed, this is also where the Grand Chef's objective happens (her recipe is in the Pantry). Use existing art for now; add a Batch 19 row for the Pantry Mimic's portrait and card-art style.

## Part 5 — Primm's fight: the rules panel, the rules
1. **The rules panel:**
   - Primm's own rules stay listed in a panel with its own scroll bar that **never overlaps the items or the player info**;
   - the run's boons, allies and curses fold into **one line** ("Run effects: 3 allies, 4 boons, 1 curse") that opens the full list on hover or click;
   - apply the same panel to every fight that lists rules;
   - mouse and controller; shots at 1280x720 and 1920x1080.
2. **Perfect Order is replaced:** "**Only one card of each type per turn**" (one unit, one spell, one tool, one infrastructure as normal), for both players. Clear tooltip; the AI follows it; tests.
3. **Mirrors** ("the first card each player plays each game is copied for the opponent") appears only in **two or three** castle fights, not every encounter. The copied card **can be paid with energy of any Path**.
4. **Primm's opening hand: 8 cards** (was 5).

## Part 6 — Rebalance Primm and the castle
**The owner found Primm too easy**, especially with dungeon boons, equipment and items.
- Simulate whole castle runs (several routes) and Primm with an endgame deck, equipment and items, after Parts 1-5.
- **Targets for a first try:** about **30 %** with no allies; about **65 %** with all four. Roughly in between for one to three.
- Tune Primm's HP, deck, rules and phases, Flex's stats and the room fights to hit them. Keep Primm tough but fair, and always with something to do.
- Report the table (allies 0-4 against the win rate), and what you changed.

## Part 7 — Items and equipment: a strength report
Some items and equipment are very strong. The owner is fine with players feeling powerful, but wants balance.
- Rank every item and piece of equipment by its effect on win rates (sim);
- propose numbers for the outliers in a table the owner can approve line by line (`docs/balance_report_nov21.md`, a new section);
- **change nothing beyond Part 1's four.**

## Part 8 — Auntie Alembic's shop: a visual overhaul
Her shop looks weird next to the other vendors. Bring it up to their standard:
- the same frame, header and gold style as the other vendor screens;
- **four glass essence jars** that fill up to 18 (with the number) and light up when selected, in place of the cramped list;
- the brew panel with a clear "pick two Paths, then brew" flow;
- the pool of possible cards in a tidy grid with hover zoom (unseen cards as card backs, the owned counts);
- a short brewing moment when a card is crafted (bubbles, a flash in the two Paths' colours, the card revealed and enlarged).

Use existing art now. Add Batch 19 rows for:
- **a custom brewing scene** for the centre (Auntie Alembic stirring a big copper cauldron, streams of the four Path colours pouring in, the scene alive);
- **an empty glass jar** (the game fills and tints it).

Before/after shots.

## Part 9 — From the review ("Fable Nov 21 review")
1. **The Arena:** apply the **bold proposed row** of every battle in the balance report's section 2. Re-simulate and report.
2. **Freed-zone lines:** write 2-4 lines each for Gary and the rep-game host after the Gainlands is freed.
3. **The credits and itch draft** keep the AI coding sentence (and the advice to tick "Code").
4. Leave the economy and the heal rooms as they are; keep the item on the backlog.
5. Update `docs/owner_backlog.md` and `docs/release/two_week_plan.md` with what this run did and what's left.

## Part 10 — Tests, build, report
1. All test shards green; the walk smokes (every zone); the NPC visibility probe; the fade probe; the quest hand-in probe; the hover-zoom probe; the puzzle solver tests; the story bots (all four Paths) through the new castle.
2. **Export 1.0.0 for the playtesters:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, at the top, under "Fable Nov 21 castle":
   - each part done or not, with shots;
   - the castle map (shots, the routes);
   - the allies and their scenes;
   - the Pantry Mimic;
   - the rules panel;
   - Primm's balance table;
   - the item strength table;
   - Alembic before/after;
   - the Arena re-sim;
   - **the Batch 19 rows** (all, with their refs placed in `Batch 19 Refs/`, each under 1 MB);
   - the dialogue revert command;
   - the zip's path and size;
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.
