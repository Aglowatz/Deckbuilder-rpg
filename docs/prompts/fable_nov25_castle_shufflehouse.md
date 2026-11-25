# Fable, Nov 25: Batch 21 imported, Primm's Castle remapped, the Shuffle House rebuilt in 3D, the owner's playtest fixes

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the Nov 24 build. Work without stopping to ask; it's fine to run long.

Read first:
- `docs/prompts/owner_list_nov25.md` (the owner's list: every item must be done);
- `docs/prompts/owner_decisions_nov25.md` (his answers to the Nov 24 inbox, and the music direction);
- the top of `docs/overnight_report.md` ("Fable Nov 24"), including its "what's left";
- `docs/overnight_inbox.md`;
- `docs/design/draft_mode.md`, `docs/art/batch21.csv`.

Run `git status`; if anything is uncommitted, check it, test it and commit it (or discard it if half-done, and say so). Tag `pre-nov25`. Log questions under "Fable Nov 25" and take the safest choice.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot process at a time; no sub-agents while Godot runs;
  - `--min-free=1200`, with test shards in small groups;
  - the story bots one after another;
  - every sim in batches of at most 30 variants, each in a fresh process, with a 20-minute limit per batch (log any timeout and move on);
  - if the owner's Godot editor or game is open, wait or run what fits.
- Commit and push after each part. No public upload.
- Shots in `docs/overnight_shots/nov25/`.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - any new art need goes in `docs/art/batch22.csv`.
- **Dialogue:** new or changed lines in `docs/dialogue/nov25_lines.csv` and `_ids.txt` for `--revert`.
- Every rule, card or quest change gets a test.

## Part 1 — Import Batch 21
- **The source:** all 29 images are approved, in `G:\My Drive\Card Game Art\Pending Review\Batch 21`, one PNG per ID. The sheet tab "Batch 21 Nov 25" and `docs/art/batch21.csv` say where each one goes. The refs (including `plan-primm-castle-v2.jpg`) are in `G:\My Drive\Card Game Art\Batch 21 Refs`.
- **How to import:**
  - copy the files into the repo and convert them the way earlier batches were (webp, sizes, import settings);
  - remove the chroma or edge fringe on the cutouts and sprites;
  - slice the four walk sheets into frames;
  - keep the old files only if something still uses them.
- **Where each one goes:**
  - DR-06 → Table Captain; NB-17 → Iron Filing Clerk (`assets/art/cards/NB-17.webp`);
  - the 8 BST squares → each Shuffled Halls dealer's fight portrait and Bestiary entry;
  - the 3 TOK images → their tokens;
  - the 4 UI-DRAFT-MODE emblems → the four mode tiles;
  - MAP-TTK and MAP-DRAFT → their maps (re-fit the curves for the new links 9–10 and Counting Room–Big Wheel; drop the drawn-arc fallback for those links);
  - SPR-DUMPWORKER-WALK-* → the mole farm hand in the Verdant Dump, now walking his route with all four directions.
  - MAP-PC is Part 2; SH-CONCEPT and the SH-TEX files are Part 3.
- **Mark Batch 21 imported** in the CSV. Before/after shots.

## Part 2 — Primm's Castle: the new map and node logic (owner item 13)
1. **MAP-PC** is a portrait cutaway, 1024x1536, with the gate at the bottom and the Model Room at the top. It follows `plan-primm-castle-v2.jpg`: 22 rooms and these 41 links:
   1-2, 1-3, 2-4, 2-5, 3-5, 3-6, 3-7, 4-8, 4-9, 5-8, 5-9, 6-9, 6-10, 7-9, 7-10, 8-11, 8-12, 9-11, 9-12, 9-13, 10-12, 10-13, 11-14, 11-15, 12-14, 12-15, 12-16, 13-16, 13-17, 14-18, 14-19, 15-19, 15-20, 16-19, 16-20, 17-20, 17-21, 18-22, 19-22, 20-22, 21-22.
   The rooms keep their encounters and events (room names are in the sheet row).
2. **Set each node** on its room's painted landing spot. Fit a path curve for each link along the painted corridor, stair or bridge. Where the art differs from the plan, follow the art and log it.
3. **Make the map scroll vertically** (mouse wheel, drag, keys and controller). It opens on the player's node and follows the player as they move. Keep the node and line sizes readable at the larger scale. Fog and question marks work as in other dungeons.
4. **Fix the duplicate nodes:** today, nodes sit underneath other nodes. Find why (an old layout left behind, nodes added twice, or a second map layer) and remove it. Add a test that every dungeon map has exactly one node per room and no two nodes overlapping.
5. **Check it all:** saves made mid-castle on the old map still load (move the player to the same room). The castle route bot and the castle sims stay green.
6. Shots: the full map, scrolled top and bottom, at mid-run, and with fog.

## Part 3 — The Shuffle House: a real 3D building with painted textures (owner item 14)
1. **Build it as a 3D model** that matches `SH-CONCEPT`:
   - a two-storey half-timbered body with depth and sides on a stone foundation;
   - three steps up to the arched double door;
   - a big-top roof with real volume, and two small turrets with flags;
   - a cobbled apron with flower beds;
   - a card weathervane.
2. **Texture it:**
   - `SH-TEX-FRONT` on the front;
   - `SH-TEX-SIDE` repeated on the sides and back;
   - `SH-TEX-ROOF` on the roof and turret cones;
   - `SH-TEX-TRIM` along the eaves.
   Light it like Crosspath's other houses, with a soft ground shadow. Make the marquee bulbs glow (a gentle twinkle is fine).
3. **Remove the old flat card on blocks.** The door, the sign, the marker, the map icon and the interaction spot follow the new model. The building stays in its current spot (the owner kept it).
4. **Shots** from the square and from the path, at the default and steepest cameras, next to SH-CONCEPT. The walk smoke, NPC visibility and fade probes stay green.

## Part 4 — The Shuffle House: Octavia, the menu, the draft screens (owner items 15–18, decisions 1 and 4)
1. **Octavia:** today she's cut off below the knees and floats. In the menu, show her whole or framed deliberately (anchored to the bottom of her panel, using the full-body sprite). In the world, her feet are on the ground with a shadow. Shots of both.
2. **Align the mode boxes:** every box has the same layout, with the title, emblem, text and buttons on the same lines (Mystery Mini sits lower today).
3. **Every box** shows "Entry Fee:" and "Rewards:" on separate lines. Mystery Mini's reward reads "Path Packs".
4. **High Rollers entry fee: 100 gold** (data, menu text, tests).
5. **Mount Swolympus** is in the Mystery Mini pool only; remove it from the Dungeon Draft list.
6. **A "Random" option next to the Path toggles,** in the same style as the toggles. It picks a random allowed set of Paths within the unlock rules and the mode's Path count. Test it with mouse and controller.
7. **The deck picker after the draft** sorts by cost, low to high (then by name).
8. **Hover Boots:** only opponents at the High Rollers table can get them. No other opponent can, including zone drafts, Classic, Dungeon Draft, Mystery Mini and the Shuffled Halls. Add a test.
9. Before/after shots of the menu and each changed screen.

## Part 5 — Music for the Shuffle House (decision 6)
- **Explore and menus:** techno carnival-casino. A driving electronic beat under carnival and casino colour (calliope or organ hooks, brass stabs, slot-machine sparkle).
- **Battles** in the Shuffle House and the Shuffled Halls: fast-paced, intense electronic combat music in the spirit of modern cyberpunk action games (pounding beat, heavy synth bass, a punchy start). Octavia's fight gets the most intense version.
- **Original music only:** no copying or sampling of any existing soundtrack. Use the game's existing music pipeline. Loudness in line with the other tracks.
- In the report, say how each track was made or sourced and its licence. If good tracks can't be made this run, wire the slots and list them in `docs/art/batch22.csv` (or a music list) for the owner.

## Part 6 — Cards and dungeon fixes (owner items 1–7, 10, 12)
1. **First Pick:** peeks at 1 card.
2. **Haunted Buffet:** costs 1 less and needs only one ingredient.
3. **Final Meal Request:** costs 1 less.
4. **Rename "Ratatouille, Rodent De Cuisine" to "Rodent De Cuisine"** everywhere: card, glossary, quests, dialogue, Bestiary, and any search or save references (old saves must still load).
5. **Vigor Mortis:** costs 1 more.
6. **Circle of Life Insurance:** costs 1 less.
7. **Global Gains Platinum Membership:** the unit has Hustle, Overtime and Bulldoze from the moment it's attached (so it can act on that turn). Only the buff happens at the start of each turn. Update the card text and add a test.
8. **Card art position:** card names cover the heads today. Shift card art down in the frame on every screen that shows cards (hand, board, deck builder, pick screens, rewards, Bestiary, shops). Use a general offset plus a per-card override in data where needed.
   - Check every card: render the full card list to contact sheets and fix any card where the name still covers a head or face.
   - Shots before and after, and the contact sheets.
9. **Test Kitchen:** the corrupted pantry effect is -5 HP (text, data, test).
10. Card text, glossary, tests. Sim the changed cards (batched) and log anything that swings much.

## Part 7 — What Nov 24 left
Do the items in the Nov 24 report's "what's left" that need no owner decision and no new art, in its order. List what you did and what's still open.

## Part 8 — Checks, tests, build, report
1. **Sims (batched):**
   - the castle routes on the new map;
   - the changed cards;
   - High Rollers at 100 gold against the economy.
2. **Scripted playthroughs:**
   - Primm's Castle from the gate to the Model Room on the new map (scrolling, no duplicate nodes);
   - one Classic Draft using Random Paths;
   - one High Rollers Draft (Hover Boots appear only there);
   - one Mystery Mini;
   - walk to the new Shuffle House and enter it.
3. All test shards green (small groups); the walk smokes; the probes; the four story bots one after another; the draft smoke.
4. **Export 1.0.0 for the playtesters:**
   - after the tests, close any other Godot;
   - `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks.
5. **`docs/overnight_report.md`,** at the top, under "Fable Nov 25":
   - each part done or not, with shots, mapped to the owner's 18 items and 6 decisions;
   - the castle remap (any differences from the plan);
   - the Shuffle House build;
   - the music (how it was made and its licence);
   - the card changes;
   - what's left;
   - the zip path;
   - the dialogue revert command;
   - the owner's decisions needed (at most 6, each with a recommendation).
6. Commit and push. No public upload.
