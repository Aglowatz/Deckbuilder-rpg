# Fable Nov 14: the owner's playtest list, the Path icon pass, Batch 16 prep

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner playtested and sent this list with screenshots.

Read first:
- the top of docs/overnight_report.md;
- docs/overnight_inbox.md;
- docs/writing/story_bible_v2.md and docs/writing/voices.md;
- docs/art/style_bible.md.

Run `git status` first; if an earlier run left work uncommitted, run the tests and commit it. Log questions under "Fable Nov 14". Tag `pre-fable-nov14`.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the low-memory guard stops a background test run, finish it in the foreground with `--from=N --to=K`.
- Commit and push after each part. No public upload.
- Before/after shots of every visible change go in docs/overnight_shots/nov14/.
- **Owner constraints:**
  - no difficulty setting;
  - no battle-board layout changes;
  - Primm's fight unchanged;
  - **no new art in this pass** (Part 6 lists what goes to the next batch).
  - Dialogue edits go through `tools/apply_dialogue_pass.js`, with an IDs file saved for `--revert=`.

## Part 1 — Story fixes

### 1.1 The Old Service Tunnels (S-CAP)
- **Remove the cut to Primm and the Wanderer** that plays inside the tunnels before the boss. It doesn't make sense there. Remove the scene and its trigger. If it carried anything the plot needs later, log it instead of moving it.
- **The boss is no longer Captain Spotless.** Confirmed: Spotless is already fought at the Capital Gate ("Keeper of the Capital Gate"), and S-CAP's node 3 is a second "Enforcer Captain Spotless".
  - Replace node 3 with **one of Spotless's officers**, sent by him to sweep the service tunnels in case anyone tries to sneak into the city. Give the officer a name and title that fit the regime's humour (a lieutenant or sergeant of the Enforcers).
  - Keep the boss's deck, HP, stats and rewards as they are; only the identity changes.
  - **Art:** reuse the existing Correction Officer art (SPR-FOE-CORRECTION-OFFICER-*, plus its bestiary or cut-out art if it has one) for now. Add a Batch 16 row for the officer's own portrait.
- **Write the before and after lines** (`dungeon.dg_s_cap_boss.before` / `.after`), the boss intro (`boss_intros.json`) and the bestiary entry for the officer. The before lines must make it clear that **Captain Spotless sent them to check the service tunnels in case anyone was trying to sneak in.** Keep the after lines' heart (the old tunnels where all four Paths once worked together). Write it in the officer's own voice, following voices.md.
- Update every other reference: S-CAP's `boss` field, the hook, the quest text, the feats, the bestiary and the tests.

### 1.2 Fragment 2 ("The Cells")
The picture shows him behind **bars**, not glass. Change the text to:
- "There are bars on every side of me, and behind the bars there are faces in white coats, taking notes."

Fix any other "glass" wording in that fragment and in every line that refers back to it.

### 1.3 Elder Maren's thread (rewrite everything she says so it fits)
**The new facts:**
- Maren **once worked at the castle**, studying the Paths and **tutoring the royal children**.
- She did **not** make the bars, and she never made or blew glass. Remove every line about glass rooms, glassblowing or her making the cell.
- **She is going blind** (very poor eyesight). That's why she doesn't recognise Tessar, the lost prince, though she tutored him. She can mention her eyes naturally (squinting, "come closer, dearie, my eyes aren't what they were").
- **After the second Path is freed,** she half-suspects who he is (something in his voice or his question reminds her of a boy she taught). She almost says it, then **dismisses it and denies it, even to herself.**
- **After the third Path is freed,** rewrite her lines so they make sense with the bars and her past at the castle. She can speak about the castle, the Paths, the royal family and the children she taught, but **no glass.**
- **After the fourth Path is freed,** remove the ending text about the warden opening only for family, and remove her saying she **knew all along.**

**The work:**
- Go through **all** of Maren's lines (every questline step, bark, epilogue line and memory scene she's in) and anyone else who mentions her past.
- Make them consistent with these facts and with docs/writing/story_bible_v2.md, and update the bible.
- Keep her voice ("dearie", gentle, warm) and every gameplay instruction exactly as it is.
- Report a before/after for each of her post-Path conversations.

## Part 2 — Fig Sly's shop
1. **Remove the supply crate** next to Fig Sly in the Crease ("Fig's Crate of Supplies"). Add an **Items** section to Fig's own shop, beside his cards, using the existing shop's filters and layout.
2. **Items showing as "?" until hovered:** find out why. If it was a deliberate "mystery stock" design, log the reason and the code path. Either way, **show every item's icon, name, effect and price** without hovering, like every other shop.
3. His portrait: the new V-FIGSLY still has two right hands. That's a Batch 16 redo (Part 6). Don't touch the art now.

## Part 3 — The world
1. **Signs:**
   - remove the empty dark signboard in the middle of the Crease (between the two service shafts);
   - remove the small sign beside the manhole in the Capital plaza;
   - **the signs in front of each service shaft show that shaft's Path icon** (from the Part 4 style guide: e.g. Gourmand's chef's hat on the shaft to the Buffet), in place of the generic purple swirl.
2. **Crosspath:**
   - Replace the polygonal faceted rocks by the water with the same painted rock props used in the rest of Crosspath.
   - **The shoreline:** make the edges where land meets water look like the Verdant Dump's shores (soft bank, natural edge, reeds or stones), not faceted polygons. Remove the odd two-tone grass gradient near the water.
3. **No enemies at zone entrances:** in every zone, no roaming enemy may wander within ~20 m of the arrival point, or of any zone entrance or exit (e.g. the junk gull flock at the Verdant Dump's entrance). Move their wander areas. Extend the existing door-distance check to cover arrival points and entrances, and run it on every zone.
4. **The Verdant Dump:**
   - remove the **floating door** on the right-hand side, and dress the spot so it looks natural;
   - remove the **big wooden platform/block** you can walk through (reference: the plank slab near the stream and conveyor), and dress the spot;
   - **the top-right area:** block it off from the middle with trees, so it can only be reached the intended way (the mount). Check the walk grid so no one can get through.
   - **Make the top-right a treasure field:** add **four more treasure chests** there, with rewards worth the trip (a mix of good gold, rare items or equipment and a pack). They must feel special next to normal chests.
     - Log each chest's contents.
     - Re-run the gold study and report the change against the ~21.2k no-grind target.
     - Include them in "The Oldest Trick in the Book" only if that quest counts these chests by design.
5. **The Endless Buffet's entrance:** remove the blocky wall that makes the zone look like it sits on a block rising out of the water.
   - The land should slope down naturally into the water (a bank or shore like the other zones), not sit on an elevated platform.
   - **Make one side of the entrance a food forest the player can't pass:** broccoli and cauliflower trees, herbs and leeks from the Buffet kit, dense enough to read as a wall. Check the walk grid.
6. **Outside the D.N.A.:** turn the bare grey apron into an **organised wasteland**, like the land outside the Capital: neat rows of tipped filing cabinets, stacked crates, queue posts, rubble and dead trees, the dead-office look.
   - Reuse the Capital's outskirts and the D.N.A. kit.
   - **Keep the floating paper effect.**
   - Check FPS on Medium.

## Part 4 — The Path icons: style guide, inventory, one consistent set
1. **The style guide:** write **docs/art/path_icon_style_guide.md**. For each of the four Paths (Beefcake, Gourmand, Refusemancer, Necrocrat) it locks in:
   - the one canonical icon (file path), its meaning and shape;
   - its colour or colours (hex);
   - its outline and background rules;
   - its minimum size;
   - where the coloured and the monochrome versions are used;
   - what it must never be replaced with.

   Base it on the icons already used most in the card frames and energy (e.g. ICON-ENERGY-B/G/N/R and the Path cost symbols), and on the owner's example "the chef's hat for Gourmand". Add the colourless or general symbol if the game has one, and the multi-Path rule. Include a one-page visual sheet (docs/art/path_icon_sheet.png) made from the canonical files.
2. **The inventory:** list **every** place a Path icon or symbol appears, in **docs/art/path_icon_inventory.csv** (place, file or scene, current icon, correct icon, fix type: code or art). Include:
   - the cards (cost icons, filters);
   - the shops' filters, the Deck Station, the collection, the packs and the Card Packs page;
   - the energy and HUD, the zone effects;
   - the map icons, the quest tracker, the feats and the glossary;
   - the service-shaft signs, the banners, the Rift Station;
   - the story stills and the painted art (the crest on the door in Fragment 4, the Wayweaver crest, the four-coloured core in the town vault);
   - the loading screens, the credits and the itch page art.
3. **The fixes:**
   - fix every **code** usage to the canonical icon now;
   - every **painted** usage that shows the wrong symbols becomes a Batch 16 row (Part 6). That includes the picture after the fourth Path is freed, where the four symbols on the arch above the King must become the four real Path icons (check whether that's STORY-MEMORY-4 or another still, and name the file);
   - if a story text describes the crest ("four signs in a ring"), make it match the real icons.

## Part 5 — Dex's matching game
- The target becomes **"Beat Dex: 20 moves or fewer"** (was 15). Update all the text in the game, the glossary and the tutorial.
- The game's hard move limit is currently 20. **Raise it to 26** so there's a margin between "beat Dex" and running out of moves. Log it.
- Update the tests and any feat that counts it.

## Part 6 — Batch 16: the art list (prepare only; the owner makes the art in ChatGPT)
Create **docs/art/batch16_nov14.csv** (the same columns as batch15_nov12.csv). Each row has a full image description in the house style, its size, the reference files and the target path. Copy each reference into `G:/My Drive/Card Game Art/Batch 16 References/`, numbered by row like Batch 15's.

**Seed rows:**
1. **V-FIGSLY (redo):** exactly **one right arm and hand, and one left arm and hand**. His right hand (on the viewer's left) is raised with a finger to his lips; his left hand (on the viewer's right) holds his coat open by the lapel. Both hands are clearly visible and attached, with no hidden or extra hand. Reference: the current V-FIGSLY.
2. **The Fragment 4 still (the picture after the fourth Path is freed):** the four symbols above the King must become the four canonical Path icons from the style guide. Everything else stays exactly as it is.
3. **Every painted asset** that the Path icon inventory marks "art", one row each.
4. **The Enforcer officer** from 1.1: a portrait (NPC-*) and optionally a cut-out, matching Captain Spotless's regime look but clearly a junior officer.
5. Anything else in the game still marked REDO in docs/art/ that would be noticeably better with new art. Pick the top 5 by visibility.

Also write **docs/prompts/chatgpt_batch16.md**, one ChatGPT prompt for the whole batch in the same format as docs/prompts/chatgpt_batch15.md (references numbered by item, house style at the top, exact file names).

## Part 7 — Verify and build
1. Walk-test every changed area at the default and Low cameras:
   - the service tunnels and their boss;
   - Maren's scenes after each Path;
   - Fragment 2;
   - Fig's shop with items;
   - the Crease and the Capital signs;
   - Crosspath's shore;
   - every zone entrance;
   - the Dump's door, block, tree wall and treasure field;
   - the Buffet's entrance;
   - outside the D.N.A.;
   - Dex.

   The NPC visibility probe and the walk-grid checks must pass.
2. All test shards green.
3. **Export 1.0.0 again** (it hasn't been released):
   - wait up to 10 minutes for at least 2.2 GB free RAM;
   - in the foreground, run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
   - If there's no memory, put the commands at the top of the report.
4. **docs/overnight_report.md**, with at the top:
   - each item from the owner's list, done or not, with before/after shots;
   - the officer's name and lines;
   - Maren's rewritten post-Path conversations, before and after;
   - why the items showed "?";
   - the Path icon guide and the inventory counts;
   - the treasure field contents and the gold study;
   - the Batch 16 list;
   - where the zip is.
5. Commit and push. No public upload.
