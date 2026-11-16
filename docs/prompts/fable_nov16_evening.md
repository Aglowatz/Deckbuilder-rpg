# Fable Nov 16 (evening): the owner's answers, the Dump entrance and camera, the Buffet's castle, forest and west edge, 1.0.0

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Read the top of docs/overnight_report.md and docs/overnight_inbox.md ("Fable Nov 16b") first. Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 16c". Tag `pre-fable-nov16c`.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`.
- Commit and push after each part. No public upload.
- Before/after shots in docs/overnight_shots/nov16c/. The owner's screenshots are in that folder as `ref_*.png`.
- **Owner constraints:** no difficulty setting, battle board unchanged, Primm's fight unchanged, no new painted art.

## Part 1 — The owner's answers to inbox "Fable Nov 16b" (apply)
1. **Item 7: the leftover non-card games.**
   - **Trivia → card quiz**, in all four zones, with the same hosts, rewards and quests. The D.N.A.'s "Pass Director Ectomund's Compliance quiz" keeps working.
   - Each question shows a **cropped piece of a real card's art** and asks "Which card is this?" (4 choices), or shows a card and asks its cost or power. Use cards from that zone's Path plus colourless.
   - It gets the same How to play screen, "?" button and win/lose panels as the new games, and the same pass mark as the old trivia.
   - **The three one-time puzzles** (the Gainlands hamster-wheel Power Grid, the Buffet's Mystery Stew Pot, the Dump's Seed Shrine) are **removed**. Each one's one-time reward goes into a chest at the same spot, and any quest step that needed the puzzle now needs the chest.
   - Update the quests, the hints, the dialogue that mentions the puzzles, and the tests.
2. **Item 19: the seals.** The four seals sit in the fixed Path order (arm, chef's hat, leaf, skull, clockwise from the top). Each locked seal shows a **faint outline of its Path icon behind the padlock**, with a hover/prompt tooltip ("Gourmand seal: locked"). When it turns, the full icon shows.
3. **Items 11, 16, 2:**
   - delete the four old unused minigame screens (`RepGameScreen`, `OrderGameScreen`, `SortGameScreen`, `TubePuzzleScreen`) and their dead code;
   - item 16 (the gate tree thinning) no longer applies, because the gate is removed (Part 2);
   - keep the compact deck-rule lines.
4. **Items 17 and 23:** keep the vault where it is, and keep the Buffet's north side as it is.

## Part 2 — The Verdant Dump's entrance from Crosspath: remove the gate trees
Ref: `ref_dump_entrance.png`. **Remove the two gate trees** (and the gate pieces cut from the thorn-wall painting) entirely. The thorns and trees that block the forest road until Moss Mulligan is beaten stay as they are.
- Dress the spot naturally from the Crosspath and Dump kits: the path, grass, a bush or two. Make sure the travel prompt, the sign and Moss Mulligan read clearly.
- Delete the now-unused gate code and art (`HubObstacles.GATE_FROM_SPOT` and the related pieces), and update the tests.
- Shots at the default and Low cameras.

## Part 3 — The Verdant Dump: the camera in the lower-right (south-east) corner
In the lower-right corner of the Dump (the chest and the lever there), the camera fights the player: it snaps, pushes in, collides or swings and doesn't follow smoothly.
- Find the cause (camera collision with the ravine rim, the wall or props, the hold-inside-bounds code added for the pale corner wedge, a bounds clamp, the occlusion fader).
- **Make the camera follow smoothly there**, at the default and Low cameras: no snapping, no fighting. The chest and the lever must be easy to see and reach.
- If the edge-wedge fix is the cause, solve the wedge another way (more dressing or fog beyond the rim).
- Record a short sequence of shots walking into and out of the corner, before and after. Check the south-west corner too.

## Part 4 — The Endless Buffet

### 4.1 The castle: a grand gingerbread house
Ref: `ref_buffet_hub.png`, `ref_buffet_forest.png`. Using **existing assets only** (the Buffet kit: BUFF-WALL-BISCUIT, BUFF-ROOF-CRUST, BUFF-DEC-ROSETTES, BUFF-TRIM-CLOTH, BUFF-SHEET-WINDOWS/DOORS, the cake and frosting paint layers, the candy props), rebuild the main castle at the back of the hub so it reads as **one giant, solid gingerbread house**:
- **Shape:** gingerbread-biscuit walls; **thick white and pastel frosting** along every roof edge, eave, window and corner (drips and piped edges); gumdrop and candy studs; candy-cane posts at the corners or door; a big frosted door.
- **More solid and grander:** one clear silhouette with a strong main roof and two towers at most. **Remove the random bits sticking out of the roof** (the stray chimneys, cranes, baskets, rods and floating pieces).
- **Colours:** warm gingerbread brown with white, pink and mint frosting and a few bright candy accents. It keeps the Buffet's palette.
- Keep every door, NPC and interaction where it works, and the walk grid unchanged.
- Shots from the entrance, the hub and the Low camera, before and after. Check FPS.

### 4.2 Fewer food trees by the entrance
There are too many broccoli and cauliflower trees immediately to the right of the Buffet's entrance; they block the view of the hub (`ref_buffet_forest.png`).
- **Remove most of them**, so the path and the hub are clearly visible from the entrance.
- **Keep the big food forest along the right (east) border**; it looks good.
- Keep any tree that blocks walking only if the walk grid needs it; otherwise use low hedges instead.

### 4.3 The west side: the gravy meets the water naturally
Ref: `ref_buffet_west.png`. On the left (west) side, the gravy river ends abruptly where it meets the outer water. A flat brown slab, a hard straight edge and a faint black outline mark where the ground used to be.
- Make it natural:
  - the river widens into a soft delta or estuary and blends into the outer water (colour and foam gradient);
  - the land slopes into the water with a soft shore (a wet band, a few crumb or pebble props), like the rest of the new edges;
  - no flat slab and no straight cut.
- **Remove the faint black line** that outlines where the ground would otherwise be, wherever it shows.
- Check the whole outer edge of the Buffet for the same line or slab, and fix it everywhere.

### 4.4 Quick checks while there
In `ref_buffet_hub.png`, check and fix if they are faults:
- a **grey, washed-out portrait or cut-out of a lady** in the bottom-left of the hub;
- the stacked **white steam columns** that look like floating discs above the fountain and the stalls (they should be soft, transparent puffs);
- a **banner pole** standing in the middle of the path.

## Part 5 — Verify and build 1.0.0
1. The walk smokes for Crosspath, the Buffet and the Dump; the NPC visibility probe; the four new minigame smokes and the card quiz; **all test shards green**. Today's earlier run stopped at shard 20, so run the whole suite.
2. **Export 1.0.0:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, with at the top:
   - each part done or not, with before/after shots;
   - the card quiz rules;
   - which chests replaced which puzzles;
   - the camera fix;
   - the castle before and after;
   - FPS;
   - where the zip is.
4. Commit and push. No public upload.
