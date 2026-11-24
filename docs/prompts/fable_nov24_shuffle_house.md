# Fable, Nov 24: the Shuffle House rebuilt, the four draft modes, the Shuffled Halls made static, the owner's playtest fixes

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the big pass's build; this is his list. Work without stopping to ask; it's fine to run long.

Read first:
- the top of docs/overnight_report.md ("Fable big pass Nov 23"), including its "what's left";
- docs/overnight_inbox.md;
- `docs/design/draft_mode.md`, `docs/design/draft_dungeon_plan.md`;
- `docs/prompts/owner_decisions_nov23.md`;
- the owner's screenshots in **`docs/overnight_shots/nov24/ref_*.png`**.

Run `git status`; if anything is uncommitted, check it, test it and commit it (or discard it if half-done, and say so). Tag `pre-nov24-shuffle`. Log questions under "Fable Nov 24" and take the safest choice. **Update `docs/design/draft_mode.md`** with the new mode structure below.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot process at a time; no sub-agents while Godot runs;
  - `--min-free=1200`, with test shards in small groups;
  - the story bots one after another;
  - every sim in batches of at most 30 variants, each in a fresh process, with a 20-minute limit per batch (log any timeout and move on);
  - if the owner's Godot editor or game is open, wait or run what fits.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov24b/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - new art needs go in `docs/art/batch21.csv`.
- **Dialogue:** new or changed lines in `docs/dialogue/nov24_lines.csv` and `_ids.txt` for `--revert`. Trey and Octavia keep their big, zany personalities.
- Every rule, card or quest change gets a test.

## Part 1 — The Shuffle House building in Crosspath (`ref_shufflehouse_floating.png`)
- **Today** it looks flat and floating, and it's hard to see behind the other buildings.
- **Give it real 3D structure,** like an actual building: a body with depth and sides, a foundation and steps meeting the ground, a roof with volume (the painted front stays the face). Make it sit firmly on the ground, with a shadow and grounding at its base, from every camera preset.
- **Move it further right and further back, into the big open area of Crosspath's back-right corner.** Move chests and trees as needed to make room.
- Keep the path to its doors clear and easy to walk, and keep it **easy to see from the town square**.
- Octavia, the sign, the marker and the map icon follow.
- Before/after shots from the square and from the path, at the default and steepest cameras. The walk smoke, NPC visibility and fade probes stay green.

## Part 2 — The Shuffle House menu: a major visual overhaul and four modes (`ref_shufflehouse_menu.png`)
**Today's grid of 17 tiles is replaced by four main modes,** each a big, clear choice. Build them in the carnival-casino look (UI-DRAFT-HALL, the `UI-DRAFT-MOCK-ARENA` design), with Octavia presenting.

1. **Classic Draft:**
   - **choose your Paths** (within the unlock rules: two Paths after the first zone, three and four after Primm), then draft and play **three random opponents**;
   - **no prismatic packs** in its rewards;
   - **Draft of the Day** sits under it, if kept.
2. **Dungeon Draft:**
   - **rewards prismatic packs**;
   - a list of the large dungeons: every zone's main dungeon, Primm's Castle, the Path-ology Lab, Mount Swolympus, the Shattered Gallery and any other large dungeon. **Each appears only after the player has cleared it once in the main game;**
   - **the Shuffled Halls** appears in this list **after its first clear**;
   - **a Random option** (a random dungeon from the unlocked list).
3. **Mystery Mini:**
   - a random mini dungeon (any dungeon with three encounters), played with the drafted deck;
   - **rewards a pack of that dungeon's Path**.
4. **High Rollers Draft:**
   - **an entry fee** (default 200 gold, in data; log it as an owner decision);
   - a Classic Draft where **the opponents can get every piece of equipment the player can**;
   - **better rewards than Classic, including prismatic packs.**
5. **The Shuffled Halls:** its own clear selection under the four modes (for example a big door below them, or a fifth, smaller tile). **Beating the Shuffled Halls is a side quest** (separate from the main quest, which only asks the player to play it once).
6. **Remove** the separate two-Path tiles, Three Paths, Four Paths, the Double-Down Table, the Full House Table and "Maps" as separate tiles. Their purpose is covered by the Path choice in Classic and High Rollers. **The arena quest line** now points at the four modes and the Shuffled Halls (rewrite its steps; for example "win a Classic Draft with each two-Path pair" can stay as quest goals inside Classic).
7. **The Path toggles don't work today, in every mode:** fix them. Make them **big rectangles you toggle on and off** (lit when on, with the Path icon and name), with a pop-up when you choose more Paths than allowed. Test it in every mode, with mouse and controller.
8. Before/after shots of each mode.

## Part 3 — Fixes in the draft screens
1. **The pick screen in the Shuffle House shows only two of the three cards:** always show three (one fewer only if the pool truly ran out, and say so).
2. **Giving up a card** (the Trade Counter, `ref_trade_counter_cutoff.png`): the card being chosen is cut off. Show it fully, enlarged and on top, with the "Swap X out" label clear of it.
3. **The rewards screen after a draft** (`ref_rewards_empty_table.png`): today it's an empty green table with three blank card spots. Replace it with a standard pop-up, centred: the result (wins and losses), the rewards as icons with names (gold, XP, packs), the kept card shown as a card, and a Finish button. No empty placeholders.
4. **The opponents:**
   - keep the opponent's tendencies and description before each fight (the owner likes them);
   - in Classic and High Rollers, **a wide variety of random NPC opponents**;
   - **their Paths and decks are random and changing, never decided by the player's choices.**

## Part 4 — The Shuffled Halls: static, hand-made encounters
1. **Every fight is preset,** like the other dungeons:
   - a fixed opponent deck;
   - fixed equipment (no random equipment);
   - its own encounter abilities and effects;
   - unique, fun, engaging and interactive (rules of the fight, scripted moments, carnival-casino twists).
2. **Today** the opponents copied the player's Path (a Necrocrat deck met only Necrocrat decks). Make every encounter static, with **its own deck in its own Paths, whatever the player drafted.**
3. **Balance** them for fun with drafted decks: simulate several player drafts (each Path, some two-Path) through every room, including Trey and Octavia. Report win rates per room and for a whole run.
4. **The Counting Halls is an optional early exit:**
   - if the player is on the right nodes, they can go there and **cash out** with some prizes (not all), and it **doesn't count as a win**;
   - today, picking it sends the player to the Big Wheel anyway: fix that;
   - say clearly in the room's description what cashing out gives and that it isn't a win.
5. **Unseen rooms show as question marks** the first time, like other dungeons. A room is revealed for later runs once the player has stepped on it.
6. Shots of the map before and after, every room, and the Counting Halls cash-out.

## Part 5 — Cards
1. **Signal Reader:** when it reveals cards in the opponent's hand, **show the actual cards**, popping up over the middle of the screen (enlarged, with a click to close), not a list of names.
2. **Plate It:** costs 1 less.
3. **Staff Appreciation Dinner:** costs 1 less.
4. **Dinner Is Served:** costs 1 less.
5. **Idiot Sandwich:** it can plate **any** unit (remove the cost limit).
6. Card text, glossary, tests.

## Part 6 — What the big pass left
Do the items in the big pass report's "what's left" that need no owner decision and no new art, in its order. List what you did and what's still open.

## Part 7 — Checks, tests, build, report
1. **Sims (batched):** the four modes' opponents and rewards against the economy; the Shuffled Halls rooms; High Rollers against Classic.
2. **Scripted playthroughs:**
   - one Classic Draft with two Paths;
   - one Dungeon Draft (a zone dungeon);
   - one Mystery Mini;
   - one High Rollers Draft;
   - the Shuffled Halls from a fresh save (question marks, the Counting Halls cash-out, a full clear against Octavia, the side quest).
3. All test shards green (small groups); the walk smokes; the probes; the four story bots one after another; the draft smoke.
4. **Export 1.0.0 for the playtesters:**
   - after the tests, with `EXPORT_LOW_MEMORY_OK=1` if needed;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks.
5. **docs/overnight_report.md**, at the top, under "Fable Nov 24":
   - each part done or not, with shots;
   - the four modes and their rewards;
   - the Shuffled Halls rooms (each encounter, its deck and twist, its win rate);
   - the card changes;
   - what's left;
   - the zip;
   - the dialogue revert command;
   - the owner's decisions needed (at most 6, each with a recommendation; the High Rollers fee is one).
6. Commit and push. No public upload.
