# Fable, Nov 23-24: the big pass (draft mode finished, the Shuffle House, Batch 20, the owner's playtest list)

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). This is one long run covering everything; **it's fine to run into the morning**. Work without stopping to ask.

## Read first (they're the brief's detail; this file sets the order and the rules)
1. **`docs/prompts/owner_list_nov23.md`:** the owner's full playtest list, by area.
2. **`docs/prompts/owner_decisions_nov23.md`:** his decisions (Trey, Octavia, the Shuffle House, the Shuffled Halls, when multi-Path opens, the new equipment and cards, the Nov 22 answers).
3. **`docs/prompts/draft_phase1_remaining.md`:** what the last run didn't finish.
4. **`docs/design/draft_mode.md`:** the agreed draft design. **Update it** with the decisions above: free entry; zone hosts offer only their zone; Open Draft only at the Shuffle House; two-Path after the first zone; dungeon rewards; the equipment rules.
5. `docs/design/draft_dungeon_plan.md` and `docs/design/draft_cards.md`.
6. The top of docs/overnight_report.md, docs/overnight_inbox.md, docs/owner_backlog.md, docs/release/two_week_plan.md.
7. The owner's screenshots in `docs/overnight_shots/nov23/ref_*.png`.

Run `git status`; if anything is uncommitted, check it, run its tests and commit it (or discard it if it's half-done, and say so). Tag `pre-big-pass-nov23`. Log questions under "Fable big pass Nov 23" and take the safest choice.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory (the PC has frozen and runs have hung before):**
  - **ONE Godot process at a time**; no sub-agents while Godot runs;
  - `tools/run_tests.sh --min-free=1200`, with the shards in small groups;
  - the story bots one after another;
  - **every sim in batches of at most 30 variants, each in a fresh process, with a 20-minute limit per batch**: kill and log any batch that hits the limit, then move on;
  - if the owner's Godot editor or game is open, wait, or run only what fits;
  - the export only after the tests.
- **Commit and push after each part** (and mid-part when a part is big), so a stop loses little.
- No public upload.
- Shots in docs/overnight_shots/nov23b/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - the main game's 45-card minimum stays (drafts have their own rules);
  - new art needs go in `docs/art/batch21.csv` (self-contained rows under 600 characters, refs under 1 MB in `G:/My Drive/Card Game Art/Batch 21 Refs/`).
- **Dialogue:** new lines for Trey, Octavia, the arena quests and the main quest, plus any rewrites the list asks for, with `docs/dialogue/nov23_lines.csv` and `_ids.txt` for `--revert`. Give Trey (a card-shark carnival auctioneer: "Pick it, pick it, PICK IT!") and Octavia (a flamboyant casino showwoman octopus, Trey's aunt and mentor) **big, zany, over-the-top personalities**, in the game's voice, family friendly.
- Every rules, card, item or quest change gets a test.

## Part 1 — Batch 20 into the game (59 pictures)
**Source:** `G:/My Drive/Card Game Art/Pending Review/Batch 20/`. All 59 are approved; the sheet tab "Batch 20 Nov 23" lists each with its use.
1. **Copy** each into its Approved folder on the Drive (leave the Pending Review copies). Import with the usual tools and compression.
2. **Wire them where their rows say:**
   - **MAP-PC:** the castle map with the eleven new walkways.
   - **UI-ALEMBIC-BREW:** four-armed Alembic, for Part 8.
   - **CAP-PROP-PRIMM-CELL:** Part 5.
   - **The draft pieces:** UI-DRAFT-BG, ICON-UI-REROLL, ICON-MAP-DRAFT.
   - **Equipment icons:** the 8 earlier draft pieces, plus the 12 new modest pieces (Part 3).
   - **MAP-DRAFT:** the Shuffled Halls map.
   - **Cards DR-01 to DR-08:** the six new cards, Octavia's card and Trey's card.
   - **Trey and Octavia:** portraits, turnaround references (for consistency only), front, side and back idles, front talk, and Bestiary/battle portraits. **Unify Trey everywhere:** portrait, sprite and Bestiary; no more badger baker or citizen stand-ins.
   - **The Shuffle House:** TOWN-HERO-SHUFFLEHOUSE, TOWN-SIGN-SHUFFLEHOUSE, UI-DRAFT-HALL (the arena menu backdrop), VS-TREY (the zone draft backdrop), BB-SHUFFLE (the battle board for every Shuffle House and Shuffled Halls fight).
   - **The mock-ups** (UI-ALEMBIC-MOCK-A/B, UI-DRAFT-MOCK-ARENA, -VERSUS, -PICK) are **designs to build from, not pictures to import**.
3. **Check:** a shot of each in place; the download size before and after.

## Part 2 — Finish Draft Phase 1 (from `draft_phase1_remaining.md`)
1. **The ban sims** (batched as in the house rules). Proposals only, apart from the owner's own removals in Part 3.
2. Fold the scripted zone draft playthroughs (the D.N.A. and the Dump) into Part 6's checks.

## Part 3 — Draft mode: the owner's feedback (the list's draft section, plus the decisions)
1. **Free entry** for every draft.
2. **Trey in a zone offers only that zone's draft;** remove the Open Draft there. Choosing Paths happens only at the Shuffle House.
3. **When multi-Path opens** (clear in menus, explanations and quests):
   - single-Path only if the arena opens before any zone is freed;
   - **two-Path drafts and two-Path cards after the first zone is freed**;
   - three- and four-Path after Primm.
   - **Prismatic packs as draft rewards only after Primm**; before that, gilded and Path packs.
4. **The draft deck builder looks and works like the main deck builder:**
   - the full deck and all the stats on the right;
   - up to all 25 drafted cards, minimum 35 including Infrastructure;
   - the player sets the amount of each kind of basic Infrastructure.
5. **The pick screen:** build it from `UI-DRAFT-MOCK-PICK`; cards enlarge more on hover.
6. **The next-opponent reveal:** build it from `UI-DRAFT-MOCK-VERSUS`. The opponent appears large in the middle before you confirm. Overhaul the zone draft menu visually (on VS-TREY).
7. **The opponents' equipment bonuses** show as battle effects under their name.
8. **Zone draft opponents:**
   - random Paths, single-Path only in single-Path drafts (any Path, including the player's);
   - decks built the draft way;
   - competitive, by sim (about 50-60 % for a sensible player draft); fudge decks if needed.
9. **The equipment pool:**
   - **remove** Gotta-Go Galoshes;
   - **remove** every piece that damages enemy units or gives them minus toughness (the Flamethrower and the like);
   - **remove** every piece whose effects are only outside battle (Hall Pass Slippers and the like);
   - **variety:** weaker pieces common, strong ones rare, no repeats of the same piece across offers in one draft unless the pool runs out, every slot well stocked;
   - **include the 8 draft pieces from Phase 1** (they were never offered);
   - **add the 12 new modest pieces** (names in the decisions file; icons in Batch 20). Give each a fitting, modest battle effect, and make each available in the main game (vendors, chests or quest rewards, early and easy to get);
   - **zone drafts:** the AI may not get the most powerful pieces (the player may);
   - **the arena's harder "win three" drafts:** the AI has the same pool as the player.
10. **The six new cards** from `draft_cards.md`, plus **Octavia Eightfold** (a four-Path legendary) and **Trey Pickett** (a Pathless epic, built around picks and offers). Design, balance (watch Bomb in the Pack in the sims), add to the draft pools and the main game's sources, tests.

## Part 4 — The Shuffle House, the Shuffled Halls, the main quest
1. **The Shuffle House in Crosspath:**
   - a carnival-casino hybrid building, placed while rearranging Crosspath (Part 5), easy to see from the town square and easy to walk to;
   - Octavia inside, the sign over the door, a map and minimap icon;
   - **it opens when all four zone drafts are won, or when three zones are freed.** Until then, a pop-up says it isn't open yet and shows where it is;
   - **the arena menu:** built from `UI-DRAFT-MOCK-ARENA` on UI-DRAFT-HALL. It holds:
     - Open Draft (choose 1-4 Paths, within the unlock rules);
     - the six two-Path challenges;
     - the three- and four-Path challenges;
     - the harder "win three" drafts;
     - the Shuffled Halls;
     - **Mystery Mini** (draft, then a random mini dungeon).
   - **The arena quest line** through every arena encounter is added automatically when the Shuffle House opens.
2. **The Shuffled Halls** (the arena's own draft dungeon):
   - on MAP-DRAFT, with the plan's 18 rooms, in the carnival-casino look;
   - **Trey is a fight inside, and Octavia is the final boss** (BB-SHUFFLE, their Bestiary portraits);
   - one HP pool, treated like other dungeons;
   - after each real fight, one pick of three: add a card, replace a card, or take nothing.
3. **The main quest:**
   - after three zones are freed, a **main quest** sends the player to the Shuffle House (opening it if the zone drafts haven't);
   - Octavia introduces it;
   - the player must **play (not beat)** the Shuffled Halls once;
   - other quests carry on alongside it.
4. **Draft dungeons beyond the Shuffled Halls:**
   - every freed zone's main dungeon, on its own map;
   - **every mini dungeon**, rebalanced for drafted decks as needed;
   - **the postgame dungeons** (the Path-ology Lab, Mount Swolympus, the Shattered Gallery and any other: list them);
   - **the vault quest** (test and balance it);
   - the same pick-after-each-fight rule everywhere.
5. **Rewards for clearing a dungeon with a draft are higher than a normal clear:**
   - the player keeps one card from the draft deck;
   - **all** the normal dungeon-clear rewards;
   - **plus an extra pack**;
   - the Shuffled Halls' first clear also gives a guaranteed draft equipment piece.
6. **Table-draft rewards:** something for every result, more for 3 wins, much more the first time each challenge is won; keep one card after a full win.
7. **Feats and Draft of the Day** from the design doc, if not already built.

## Part 5 — The world and the towns (the list's "World and towns", plus Primm's cell)
1. **The opening scene's foreground tree** (`ref_opening_tree.png`): move or remove it so the hero, the Rescuer and the cave read clearly.
2. **Crosspath:**
   - move the Deck Station to the other side of the main fountain;
   - place the Shuffle House;
   - rearrange so everything fits, looks good and is easy to walk around;
   - move the key chest further from the well;
   - replace one bear farmer and one badger with different NPCs not already in the square, and give the farmers moving walk routes.
3. **The store-room ghosts' art** disappeared: find out why and put it back.
4. **The Capital's underground base after Primm is defeated:** declutter it, keep the rift clear, and put **Primm behind the CAP-PROP-PRIMM-CELL bars**.
5. **Trey's spots:**
   - in the Verdant Dump, on the first tier near the entrance, left side;
   - in every zone, not always next to Dex, but near the starting areas.
6. Walk smokes and NPC visibility for each zone touched; before/after shots.

## Part 6 — Quests, cards, items, shops (the rest of the list)
1. **Quest NPCs:** talking to an NPC who has a quest gives the quest dialogue and its steps in that one conversation.
2. **Participation Trophy:** experience boost 15 %.
3. **Global Gains Platinum Membership:** costs 2 less; attaching costs 1; gives Hustle, Overtime and Bulldoze; no return to hand.
4. **Let Them Eat Cake:** costs 1 less.
5. **One display order for equipment and items, on every screen** (`ref_equipment_text_order.png` shows the problem): name; slot and rarity; what it does; flavour text. Check the armory, the shops, the Character page, the draft picks, the reward screens and the tooltips.
6. **Pip's cloak dyes:** preview the tinted cloak icon (ICON-COS-PLAINCLOAK), not the hero's whole body.
7. **The Nov 22 answers:**
   - soften the Pantry Mimic to about 28 HP and re-sim the castle routes;
   - colour only the keywords that belong to one Path;
   - everything else stays.

## Part 7 — Dungeon maps: lines that follow the painted walkways
Today the line between two nodes is straight and crosses the picture.
- Give every dungeon map **path curves in data** that follow its painted walkways (a polyline or curve per link). Fit the node spots to the painted landing spots.
- Do it for every existing map (the zone dungeons, the minis, the castle, the postgame dungeons) and the new MAP-DRAFT. Trace them from the images.
- Write a small check that shows each map with its curves, for the owner's review.
- Where a painting has no walkway for a link, draw a tidy curve and add a Batch 21 redo row naming exactly what's missing.
- Shots of every map.

## Part 8 — Auntie Alembic: the complete rebuild
- Build her screen from **mock-up B** (`UI-ALEMBIC-MOCK-B`): the four essence jars along the bottom; **the circle of four Path sockets surrounding Alembic at her cauldron** (four-armed UI-ALEMBIC-BREW), where the chosen Paths light up and pour in; the Brew button under her.
- **With one change: the card panel on the right is lighter and brighter, like mock-up A's**, not the dark panel.
- **Brews of two Paths, then three and four Paths after Primm,** with the directions and the socket count following the unlock.
- A modern, high-quality indie crafting menu: clear, readable, mouse and controller, hover zoom on the cards, the brewing moment kept.
- Before/after shots at 1280x720 and 1920x1080.

## Part 9 — Checks, balance, tests, build, report
1. **Sims (batched):**
   - the zone drafts and arena drafts (rival win rates; the equipment pool after the removals);
   - the Shuffled Halls (Trey and Octavia);
   - one draft run of each other dungeon type;
   - the castle routes after the Pantry Mimic change;
   - rewards against the economy.
2. **Scripted playthroughs:** a zone draft in each of the four zones; the Shuffle House opening (both ways in); the main quest's Shuffled Halls run; a Mystery Mini; one zone dungeon draft.
3. All test shards green (small groups); the walk smokes (every zone); the probes; the four story bots one after another; the draft smoke.
4. **Export 1.0.0 for the playtesters:**
   - after the tests, with `EXPORT_LOW_MEMORY_OK=1` if needed;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke (with the export's own pack) and the three `play_exported.sh` checks (0 SCRIPT ERROR).
5. **docs/overnight_report.md**, at the top, under "Fable big pass Nov 23":
   - each part done or not, with shots;
   - the Shuffle House and the Shuffled Halls;
   - the draft screens against their mock-ups;
   - the equipment pool (what's in, what's out, the 12 new pieces' effects);
   - the new cards;
   - the map curves;
   - Alembic before/after;
   - the sim tables;
   - the Batch 21 rows;
   - the dialogue revert command;
   - the zip's path and size;
   - what's left;
   - the owner's decisions needed (at most 6, each with a recommendation).
6. Commit and push. No public upload.
