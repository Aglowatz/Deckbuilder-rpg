# Fable, night of Nov 20-21: the owner's playtest list, cards, dungeons, the Deck Station, the castle scene, five cameras

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the Nov 20 build; this is his list. His screenshots, if any, are in `docs/overnight_shots/nov20/ref_*.png`.

Read first:
- the top of docs/overnight_report.md ("Fable Nov 20") and docs/overnight_inbox.md;
- docs/owner_backlog.md;
- docs/writing/story_bible_v2.md;
- docs/art/path_colour_guide.md.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 21". Tag `pre-fable-nov21`. Work in this order; if time runs short, finish the part you're on, skip to Part 11, and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov20/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged (the entry scene changes, Part 8);
  - no enemy intent shown;
  - no combat pacing changes;
  - no new painted art (Batch 18 rows instead);
  - each zone keeps its own colour grade;
  - family friendly.
- **Dialogue:** single-line changes plus the rewrites asked for here. IDs go to `docs/dialogue/nov21_lines_ids.txt` with `docs/dialogue/nov21_lines.csv` for `--revert`.
- Every rules, quest or card change gets a test.

## Part 1 — The owner's decisions from "Fable Nov 20"
1. **Gourmand's lighter blue (`#5AAAF2`) stays.** Remove the "alternatives" note or mark it as not chosen.
2. **The Rusty Grave Shovel stays as is** (Toxic and Swat, no stat bonus).
3. **Wild Growth stays uncapped.**
4. **The Heart Roots node keeps its two options** ("Give blood", "Walk on").
5. **The well's key gets a chest of its own:** a small chest near the well holds the key for "The Door Under the Well". Shiro Swindle's prank chest goes back to being only his (50 gold, starts his questline) and no longer holds the key. Update Maren's lines and the quest steps to point at the new chest. Walk the quest end to end; keep the hand-in probe green.
6. **The Arena puzzles:** no change; the owner play-checks them later.

## Part 2 — Cards (each with a test, and the card text, glossary and docs updated)
1. **The sacrifice-to-damage bug (owner's report):** cards that let you **sacrifice a unit to deal damage to the opponent** can't target the opponent. Find every card and ability of this kind (search the card data and the effect code for sacrifice plus damage), fix the targeting so the opponent's hero (and units, where the text allows) can be targeted with mouse and controller, and check the AI can still use them. Report the root cause and every card it affected. Add a test per card that it can target and damage the opponent.
2. **Overdue Library Book:** "draw 1 extra card, then discard 1 card at random" (was draw 2, discard 1).
3. **Cost changes:**
   - Soul Food Kitchen: **2 total**, one Necrocrat and one Gourmand;
   - Food Fight: **2 total**, one Gourmand and one Refusemancer;
   - Community Garden: one less Pathless;
   - Undead Lifter: one less Pathless.
4. **To Die For:** "Destroy target unit" (the "defence 3 or less" limit goes).
5. **Renames everywhere** (UI, card text, glossary, tutorials, dialogue, docs, save-safe ids unchanged unless they're shown):
   - **"Colorless" / "Colourless" → "Pathless"**;
   - **"Patchwork Cloak" → "Pathwork Cloak"** (the kingdom of Patchwork keeps its name).
   Grep afterwards; report anything left on purpose.
6. **The AI's opening hands:** every AI opening hand has **at least two resources**, except in the tutorial fights and the Opening Forest. Mulligan or redraw by the existing rules, so it's fair and seeded. Captain Spotless got stuck with none: test his fight and the Arena's fights. Tests for the rule and the exceptions.

## Part 3 — Three-Path and four-Path cards wait for Primm
1. **No 3- or 4-Path cards from any source** (packs, rewards, chests, shops, Alembic) **until Primm is defeated.** After that, they are allowed in decks and are given as rewards and sold as normal.
2. Cards already owned stay owned; they simply can't be in a deck until then.
3. **The game explains it:** a short line when the player first sees one (or in the Deck Station's help and the glossary), and after Primm, a notice that they're now unlocked.
4. **The red "ineligible Path" notice at the bottom becomes a pop-up the player must confirm** (OK), with the card's name and the reason. Mouse and controller.
5. Tests: pools before and after Primm for every source; a locked card can't be added; the pop-up; the unlock notice.

## Part 4 — Dungeons: no full heals, more interesting choices
1. **No full heals in the main-zone dungeons.** Every full-heal option there becomes **"Heal 5 HP for a cost"** or **"Do nothing"**.
2. **The costs, chosen per node, harsher deeper in:** gold; a random card removed from the deck for the rest of the run; or a drawback in the next fight.
3. **New, more creative drawbacks** for the choice nodes (add the code, use them in several nodes), for example:
   - the first unit you play next battle has -2 attack;
   - your units enter exhausted next battle;
   - draw one less card on your first turn;
   - the opponent starts with 2 extra HP;
   plus a few of your own in the same spirit. Keep the existing rule: no purely good option.
4. The mini dungeons and the castle keep their own rules unless one has a full heal (report it; don't change the castle rooms).
5. Update the choice-node table in the report; tests for each new drawback.

## Part 5 — Menus
1. **Deck Station Path filter:**
   - Path toggles; the player may select up to as many Paths as their deck allows;
   - **none selected shows all cards**; once one or more are selected, show only the cards that a deck with those Paths could use;
   - Pathless cards show only when specifically tagged;
   - **a pop-up** when they try to select more Paths than allowed.
2. **Deck builder keyword search:** a search box that matches names, card text and **keywords** (Reinstate, Swat, Hustle, Toxic and the rest), alongside the Path filter.
3. **The Wardrobe's "Your Look":** remove the character preview with hats; preview **the item by itself**, like Pip's shop. If any item lacks a standalone picture, use the best existing one and add a Batch 18 row.
4. **The Packs menu: "Open all" includes the gilded packs.**
5. **Rewards wait for a click:** chest and item rewards (e.g. the "Head Chef's Ladle" only flashed briefly) show an icon you can **hover for its full info**, and the player must click or press to continue. Check every reward path (chests, quest rewards, fight rewards, dungeon nodes).
6. **Every card enlarges on hover everywhere,** including all reward screens (the Toro Toro reward card was small and didn't enlarge). Write a probe that lists every screen that shows a card and checks it has the hover zoom; keep it as a test.
7. **Mid-fight speech and event pop-ups,** one layout in every fight:
   - the event name at the top;
   - a full blank line;
   - the complete effect description;
   - a full blank line;
   - the dialogue, the speaker's name in **bold**.
   Apply to every scripted fight; shoot three.
8. **Small grey text:** the quest log's unknown steps and the level-up pop-up's "XP toward level N" get the same contrast fix the quest box got.

## Part 6 — The camera: five presets on V
- Pressing **V** cycles through **five presets**: pitch **+6, +8, +10, +12, +14** degrees from the original default, each a little further out as it gets steeper so the view stays comfortable. A small toast names the preset ("Camera 3 of 5: +10°").
- The Settings rows stay and match the current preset; the choice is saved.
- **The default is +6** (replacing +4).
- Shoot all five in Crosspath, the D.N.A. and the Buffet; check the fade rules still behave at the steepest.

## Part 7 — The world
1. **Omakase (the Buffet's sushi mini dungeon):**
   - give it a sushi pun name (e.g. *The Raw Deal*, *Roll Call*, *Fin-ished Business*, *Wasabi Wasabi*, or better); update every mention;
   - still entered through a walk-in freezer, but the outside looks like a **sushi spot** (noren curtain, lanterns, a sign, a little counter) from existing assets; add a Batch 18 row for a painted sushi front and sign;
   - **move its entrance to the right side of the map, behind Colonel Casserole,** so he must be beaten to reach it (today it's next to the main dungeon). Its quest, marker and sealed message follow.
2. **See-through windows:** move the trees, the D.N.A. cabinets and the Iron Cave's rock onto the same round window and hero outline as the buildings (the fade shader's include, batched meshes too). Keep the fade probe green; FPS before and after.
3. **Quests track on start:** a quest that starts on its own (like the "Under the Old Well" follow-up) becomes the tracked quest, with a short toast.

## Part 8 — Story
1. **Maren after the fourth zone:** she talks about her staff: she has leaned on it for as long as she can remember. Remove "never told a soul why".
2. **Primm's Castle entry, rewritten:**
   - Elowen is being arrested as the Wanderer arrives; he sees her, but she's taken before he reaches her (no interaction with her);
   - **Plume** reads out her name and the charges;
   - Elowen shouts to him to **stop Primm** and **not to follow her**;
   - he understands he must hide and defeat Primm, and he listens (she is rescued in the postgame);
   - in the existing voices; update the story bible and the registry; play it and shoot it.

## Part 9 — Batch 18 (rows only, in `docs/art/batch18_nov18.csv`)
1. **Hold** the 11 info-screen rows (UI-INFO-*, UI-QUESTBOX, UI-QUEST-MARKS, UI-INFO-TOOLTIP, UI-MAP-FRAME): mark them "on hold, the owner is rethinking the look" in a status column, or move them to `docs/art/batch_hold_info_screens.csv`.
2. **The Doppelganger's two pictures before the final fight** don't match each other. Add **remake rows for both**, consistent with each other (the same character, the same background) and with her other pictures and her dialogue descriptions. Name the files, list what differs today, and write a short character and background description both rows share.
3. **Add** the Omakase sushi front and sign (Part 7) and any Wardrobe item pictures that are missing (Part 5).
4. Every row: the exact file path and size, a self-contained description under 600 characters, and the refs to open (small, existing files).

## Part 10 — New info-screen mock-ups (design only)
The owner rejected the Nov 19 mock-ups: he wants **more colour, inspired by the four Paths** (Necrocrat violet, Gourmand blue, Beefcake red, Refusemancer moss green), still in the painted storybook style.
- Make **two different directions**, each as mock-ups of the quest box, the main menu, the quest log, a tooltip and a settings page, in `docs/overnight_shots/nov20/ui_mockups_v2/`.
- A short note on each in `docs/art/ui_style_guide.md`. Build nothing; no art rows until the owner picks.

## Part 11 — Tests, build, report
1. All test shards green; the walk smokes (every zone); the NPC visibility probe; the fade probe; the quest hand-in probe; the hover-zoom probe; the puzzle solver tests.
2. **Export 1.0.0 for the playtesters:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, at the top, under "Fable Nov 21":
   - each part done or not, with shots;
   - the sacrifice-to-damage bug: the cause and the cards fixed;
   - the choice-node table with the new costs and drawbacks;
   - the three-Path rule and where it's explained;
   - the Omakase name, its new spot and the shots;
   - the castle entry scene;
   - the Batch 18 rows added or held;
   - the mock-ups;
   - the dialogue revert command;
   - where the zip is;
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.
