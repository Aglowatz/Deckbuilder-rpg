# Overnight Nov 17-18 (Opus): 81 new images, the D.N.A. rebuilt as an indoor grand hall, the owner's decisions

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep.

Read first:
- the top of docs/overnight_report.md and docs/overnight_inbox.md ("Overnight Nov 17");
- docs/review/critic_nov17/04_art.md, triage.md and l_plans.md (the D.N.A. "dress the corridors" plan is replaced by Part 2 below);
- docs/art/batch17a_dna.csv (17 rows) and docs/art/batch17_nov17.csv (64 rows);
- docs/art/path_icon_style_guide.md.

Run `git status` first; if anything is uncommitted, run the tests and commit it (this includes the new files in docs/prompts/ and docs/art/). Log questions under "Overnight Nov 18". Tag `pre-overnight-nov18`. Work in this order; it's the priority order.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. **No export tonight** and no public upload.
- Before/after shots in docs/overnight_shots/nov18/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight unchanged (numbers and rules), and the castle rooms unchanged;
  - approved art is not repainted (adjusting it for import is fine: crops, seams, scale);
  - dialogue: single lines only, with an IDs file for `--revert`;
  - don't reverse any recorded owner decision.
- **Each zone keeps its own colour grade.** No shared grade across zones.

## Part 1 — Import the 81 images (the owner approved all of them)
**The files:**
- **Batch 17A, the D.N.A. hall (17):** `G:/My Drive/Card Game Art/Approved_ZoneKits/DNA/`, the 17 IDs in docs/art/batch17a_dna.csv.
- **Batch 17 (64):** each file's exact path is in docs/art/batch17_nov17.csv. Note that 11 of them are not in their usual folders, and older versions with the same name still exist elsewhere:
  - in `Approved/` (the plain folder): UI-CARDBACK-R / -G / -C, MAP-S-CAP, BB-S-CAP, UI-PACK-G, NPC-PLAYER_CONFUSED, NPC-PLAYER_DETERMINED;
  - in `Approved_NPCs/`: NPC-ELDER, NPC-ELDER_HAPPY, NPC-ELDER_WORRIED.

  **Always import the copy listed in the CSV (the newest).** Then copy (don't delete) each older same-named file into `G:/My Drive/Card Game Art/Superseded/Batch 17 replaced/`, and move the new one into its usual folder (Approved_UI, Approved_Maps, Approved_Battleboards, Approved_Characters) so each ID exists once. If the harness refuses a Drive move, log it and carry on.
- Ignore `Approved_ZoneKits/DNA/00_DONE_DNA_WALL_HALL-A.png`; it is a duplicate of DNA-WALL-HALL-A. Move it to Superseded.

**Import fixes:**
- **DNA-FLOOR-MARBLE** is 3 checker squares across, so it doesn't tile: crop it to an exact 2x2-square tile, then check the seams.
- **DNA-RAIL-PARTITION** fills only the top third of its canvas: crop to the painted area.
- **Seams:** the tileable pieces (the three hall walls, the exterior wall, the partition, the floor, the runner) must tile with no visible seam. Fix the edges (offset and blend, or mirror) where needed, and screenshot each tiled 3x.
- **TOWN-PROP-CELLAR-FOURSEALS-OPEN:** the doorway and stairs are partly transparent. Fill the opening with an opaque dark backing (painted-dark brown-black, not flat black) so nothing behind the door shows through.
- ChatGPT made most images smaller than asked (about 1254 px). Use them as they are, scaled to the slot; don't upscale with filters that add mush.

**For every image:** run the importers one Godot at a time; mark the CSV row "In game"; screenshot it in the game; check it against the Path icon style guide. Report the build size change against docs/build_size_policy.md.

## Part 2 — The D.N.A.: rebuild as one enormous grand hall, indoors (the owner's choice)
**The target:** the owner's concept painting `Approved_ZoneKits/DNA/Haunted Office of Necrotic Affairs.png` (the mood, materials and light) and the layout of `PAINTOVER-DNA-HUB.png` (open floor, low partitions you can see over, the Hall of Final Approvals at the far end). **It must feel indoors:** a cathedral-sized haunted government lobby at night. **The art critic gave the zone 3.5/10; the goal is to make it one of the best-looking zones.**

Shoot the hub, arrival, door, mid1 and mid2 at the default and Low cameras **before** you start.

**Keep exactly:** the walk grid, routes, NPC positions, doors, quests, the dungeon entrance and every interaction. Only the look changes. The outside wasteland approach stays as it is.

1. **Walls:**
   - **The tall inside walls** (the roofless "room" boxes and corridors) become **waist-high partitions** (DNA-RAIL-PARTITION, with DNA-RAIL-POST at every end and join) on exactly the same footprints, with the same collision. The camera sees over them.
   - **The outer walls** of the hall become two-storey hall walls: DNA-WALL-HALL-A and -B alternating (never the same bay twice in a row), with DNA-WALL-HALL-NARROW for short runs and corners. Line up the shared heights so the wainscot, gallery and cornice run level all the way round.
   - **The outside faces** of the building (seen from the wasteland and the arrival) use DNA-WALL-EXTERIOR.
   - The roofless rooms become **office booths** (DNA-PROP-OFFICE-BOOTH-01 / -02) standing inside the hall along its sides; keep any NPC who stood in a room at the same spot, in or beside a booth.
2. **The floor:** DNA-FLOOR-MARBLE everywhere inside; DNA-FLOOR-RUNNER as long red carpets along the main walking routes (the path from the entrance to the Hall of Final Approvals, and to the main NPCs).
3. **The far end and the sense of a ceiling:**
   - DNA-BD-HALL-INTERIOR closes the north end, where the outdoor skyline and sky show today. **From inside, no sky, skyline or clouds may show at any camera.** Where the camera would see above the walls, it sees dark vaulted shadow.
   - DNA-PROP-COLUMN stands in rows on the hall floor, rising out of the top of the frame.
   - DNA-PROP-CHANDELIER hangs over the open floor, its chain going up out of frame, swaying very slightly (off on Low-end).
4. **The landmark:** DNA-PROP-LOBBY-CLOCK replaces the faceted grey orb on its stand, at the same spot.
5. **Dressing:** DNA-PROP-SCONCE on the wall pilasters (replacing the white light rectangles); DNA-BANNER-STAMP-01 / -02 hanging from the gallery and on posts; the blank signs show the icons from DNA-SHEET-SIGNS (stamp, clock, arrow, folder, raised hand, ghost) to match what they point to; existing kit props (desks, cabinets, paper stacks, ghost lamps, queue ropes, the ghost queue) placed with care, not scattered.
6. **Light (indoors at night):** warm gold from the chandeliers, sconces and lit booths; soft green ghost-flame as the accent; cool pale moonlight shafts slanting in from the tall windows onto the marble; deep shadow overhead and at the edges. Readable and warm, never murky. A few slow dust motes in the light shafts (off on Low-end). Keep the D.N.A.'s own colour grade, tuned to this look.
7. **Check it:**
   - after shots at the same five spots and both cameras;
   - a short walk sequence from the entrance to the Hall;
   - the walk smoke for the D.N.A. and the NPC visibility probe;
   - every NPC still reachable;
   - FPS on Medium and Low-end (report before and after).

## Part 3 — Wire in Batch 17 (where each image goes is in batch17_nov17.csv)
- **The five ruler statues, standing and toppled**, replace the flat grey-tinted cut-outs on the existing plinths, in each zone hub. Standing before the zone is freed, toppled after. Same scale for all five. Screenshot each, both states.
- **The card backs, the packs, the tunnel map and battle board, Maren's three portraits, the Dump pennants 07 / 08, ICON-NODE-WELL, CUT-QUADZILLA**: swap in where the CSV says. Remove any code overlay that drew a Path icon over old art where the new art already shows it.
- **The Bestiary:** the seven BST-ECHO-OF-* pictures and BST-THE-PERFECT-COPY fill the Shattered Gallery entries.
- **The hero's teal cloak:** NPC-PLAYER_CONFUSED and _DETERMINED replace the grey-brown ones. Then **check every other picture of the hero** (world sprites, battle or cutscene art, the Wardrobe default) and log any that still show the old cloak colour as Batch 18 rows.
- **The vault:** TOWN-PROP-CELLAR-FOURSEALS-CLOSED / -OPEN replace the box-built cellar door; TOWN-PROP-SEAL-LOCKED on the locked seals (with the faint Path icon outline as now) and TOWN-PROP-SEAL-BLANK with the full icon drawn on top when a seal turns. Keep the four seals in the fixed order (arm, chef's hat, leaf, skull, clockwise from the top). Shots of locked, 2 of 4, and open.
- **The card games:**
  - Reps: MG-PROP-BENCH, MG-PROP-BARBELL and MG-PROP-PLATE-01..04 (one plate per correct guess, on alternating ends, heaviest first);
  - Order Up: MG-BG-PASS, MG-PROP-TICKET (the game writes the target on it), MG-PROP-BELL;
  - Sort It Out: MG-BG-CONVEYOR, MG-PROP-BIN-01..04 (the game draws the type icons on the plaques);
  - File in Order: MG-BG-FILING, MG-PROP-CABINET, MG-PROP-STAMP-APPROVED / -REJECTED for the win and loss.

  Screenshot each game's How to play, mid-game and win screens.
- **The Buffet:** BUFF-PROP-FRUIT-TART and BUFF-PROP-CAKESTAND-TALL in the east food forest; BUFF-SHEET-FLIERS animates the butterflies and birds (off on Low-end); BUFF-PROP-VEG-01..03 replace the untextured green spheres in the hub's vegetable patch.
- **The Dump:** DUMP-PROP-PIG replaces the pink cube.
- **Crosspath's world map:** MAP-WORLD-TOWN replaces the blurry blocky map; line up the pins and names with it.

## Part 4 — The owner's answers to inbox "Overnight Nov 17" (apply)
1. **The deck minimum stays at 45.** Don't change deck rules. You may still improve combat pacing through feel and clarity (feedback, readable enemy turns, reward moments); report any numbers you change, with sims before and after per Path.
2. **Primm's Standing Army and the castle's 4th room: no change.**
3. **Elowen's name line ("Elowen. It's Elowen. I promised."): yes.** Add it as the critic proposed.
4. **The hero's own voice in the finale: yes.** Replace the two quoted lessons with lines in the hero's own voice, as proposed. Single lines; add them to the IDs file.
5. **One shared colour grade: no.** Each zone stays distinct.
6. **The Opening Forest brightness and rim light: no.**
7. **A boss intent strip during setup turns: no.** (The owner doesn't want enemy intent shown.)
8. **Reps keeps the streak after a miss: yes.**
9. **"Free the Four Zones" auto-starts: keep.**
10. **The tracker names "The City Gathers" / "After the Fall": keep.**
11. **The hero's cloak: teal.** (Part 3.)
12. **The Nov 16 leftover lines: approved.** Apply them (Maren's "holding yours", "Four banners...", "find me on the square", "I still can't see her face", "a coat too fine") if not already in.

Save every changed line's ID to `docs/dialogue/nov18_single_lines_ids.txt`, with the CSV, so `node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov18_single_lines.csv --revert=docs/dialogue/nov18_single_lines_ids.txt` undoes them.

## Part 5 — Small leftovers (check, fix if faulty)
- The Verdant Dump's two south corners (grass slopes, no pale wedge, the camera smooth) at the default and Low cameras.
- The castle's last chimney (no floating or clipping piece).
- The waist-high hedge by the Buffet entrance (it shouldn't block the view of the path or look like a wall).

## Part 6 — Plans for the next small art batch (prepare only; no new art tonight)
The world maps of the Gainlands, the Endless Buffet, the Verdant Dump, the D.N.A. and the Capital are still blurry and blocky. For each, make a clean **top-down plan image** like the one used for Crosspath (2048x2048, north up, the walkable areas, water, roads, the main buildings and landmarks as simple shapes, no text), so ChatGPT can paint a parchment map that matches the layout.
- Save them to `G:/My Drive/Card Game Art/Batch 18 Refs/` as `plan-gainlands.jpg` and so on (JPG, under 400 KB each).
- Add five rows to a new `docs/art/batch18_nov18.csv` (IDs MAP-WORLD-GAIN, -BUFF, -DUMP, -DNA, -CAP), with any hero-cloak rows from Part 3 and anything else that only new art can fix. Use the same columns as batch17_nov17.csv, plus the description and references.
- The owner runs ChatGPT from a Google Sheet tab, so keep each description self-contained and under 600 characters.

## Part 7 — Tests and report (no export)
1. All test shards green, the walk smokes (Crosspath, Gainlands, Buffet, Dump, D.N.A.), the NPC visibility probe, the card-games smoke, and the strict playthrough bot for one Path as far as Primm.
2. **docs/overnight_report.md**, with at the top:
   - the D.N.A. before and after (all shots), FPS before and after;
   - the import table for the 81 images (each "In game", with a shot or the reason it isn't);
   - the statues, the vault, the card games and the Buffet forest, before and after;
   - Part 4, each answer applied, and the dialogue revert command;
   - Part 5 results;
   - the Batch 18 rows and where the plans are;
   - the build size change;
   - anything that needs the owner (at most 8 items, most important first, each with a recommendation).
3. Commit and push. No export, no public upload.
