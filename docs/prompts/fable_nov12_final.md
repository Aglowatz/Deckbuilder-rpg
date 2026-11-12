# Fable final day (Nov 12): world finish, Batch 15, late-game re-score, RC6

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). This is the last long pass before the owner releases 1.0 by hand on a
smaller plan.

Read first:
- the top of docs/overnight_report.md (Fable Nov 11-12);
- its "What was not done" section;
- docs/overnight_inbox.md, "Fable Nov 12";
- docs/art/style_bible.md.

Log questions under "Fable Nov 12b". Tag `pre-fable-nov12b`.

**The target:** the 3D world (5.4-5.6) closes the gap to the painted layers (7.4-7.6), and the late game reaches 7 / 6 / 7.

## House rules (same as last pass, plus)
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot at a time; no sub-agents while Godot runs;
  - use `tools/run_tests.sh --min-free=900`;
  - before any export, wait until free RAM is at least 3 GB. If it isn't, log it and ask in the inbox instead of starting.
- **Commits:** commit and push after every part, and at least every 90 minutes. No public upload.
- **Before/after:** every visual change gets a before/after pair from the same camera, in docs/overnight_shots/nov12b/.
- **Owner constraints:**
  - no difficulty setting;
  - no battle-board or menu layout changes;
  - approved paintings stay as they are, except where Batch 15 replaces one;
  - Primm's fight unchanged;
  - Medium holds 60 FPS (the Capital included); Low keeps its numbers;
  - the zip grows at most ~10%.

## Owner decisions (inbox "Fable Nov 12")
| Item | Decision |
|---|---|
| 1 (the hand-size replacements) | Accepted. |
| 2 (the entrance roamer is beaten once per save) | Keep. |
| 3 (blocking buildings fade fully) | Keep. |
| 4 (the flat wash on untextured surfaces) | Keep. |
| 5 (the Capital crowd and its six new lines) | Keep. |
| 6 (the fountains run again) | Keep. |
| 7 (the smiley emblem) | Keep. Batch 15's painted easel portraits replace only the easel smileys. |
| 8 (the brighter D.N.A.) | Keep. |
| 12 (the funeral's map entry) | Keep. |
| 11 (the critic's design asks) | **Do two of the three:** (a) a dungeon room's type shows one step ahead (a room's type is visible once you can reach the room before it); (b) every level-21+ castle fight's three reward cards include at least one Uncommon or better. **No** "Retry this phase" (Primm unchanged). |

## Part 1 — The world's remaining faults, the code-fixable half (the biggest share of the day)
From the "What was not done" list and the after-critic's top 25. In order:
1. **Contact shadows:**
   - every character and roaming enemy gets a soft, clearly visible ground shadow, sized to the sprite and darker on Medium;
   - every prop placed on the ground gets a little ambient darkening at its base (a decal or a vertex-AO ring).

   This is the cheapest "sits in the world" fix and both critics asked for it.
2. **Blended ground:**
   - in the Gainlands, the Buffet and the Dump, ground materials blend at their edges with a noise mask (grass to dirt to stone; no hard seams or straight lines);
   - break up big tiling surfaces with a second scale of the same texture, or with random rotation and stochastic tiling (the fortress brick, the mats, the D.N.A. floor, the Capital wall);
   - scatter edge foliage and grass clumps along walls, paths and cliffs, from the existing kits.
3. **Water:** one shared stylised water shader (a depth tint, soft edge foam, slow scrolling ripples and a sky reflection tint) for the fountains, the Dump's stream and the Gainlands sea. It replaces the flat blue and grey.
4. **Map edges and voids** (#14): every zone's view at the default and Low cameras shows no void, strip or bare ground edge. Use cliffs, hedges, rubble or backdrop cards from the kits, plus fog at the edge.
5. **Stray quads and foreground obstructions** (#12, #21): no giant billboard, quest marker or paper quad fills the Low camera, and nothing big sits between the lens and the hero for more than a moment. Scan each zone with the shot driver.
6. **Duplicate and broken sprites** (#22): find and fix them.
7. **The Capital's Transit Yards ghost buildings** (#3).
8. **Faceted low-poly props** (#6): smooth-shade or bevel the hedges and statues; raise the segment count on round things. Leave anything Batch 15 replaces.
9. **The scale audit as a measured table:** doors, counters, benches and NPCs in every zone against the style bible's ratios. Fix the outliers.
10. **Hub storytelling clutter:** 6-10 meaningful dressing props per hub from each zone's kit (market goods, signs, decals, debris), placed with intent.
11. **Light:**
    - add warm light sources where the art implies them (lamps, windows, forges, glowing pickups), budgeted per zone;
    - give each zone without one (Crosspath, the forest, the Dump) a gentle per-zone grade;
    - don't add SSAO; contact shadows and baked base darkening stand in for it.
12. **The world motion list:**
    - pickups bob and glow;
    - doors and chests animate open;
    - ambient life per zone (birds over the Gainlands, steam in the Buffet, flies and drifting spores in the Dump, paper motes in the D.N.A., sparkles in the Gallery);
    - castle rooms escalate in music as well as look.

Measure FPS on Medium and Low in Crosspath, the Capital, the Buffet hub and a battle after items 2, 3 and 11.

## Part 2 — Import Batch 15 (whenever it lands)
- The owner is generating the 32 images now in ChatGPT. They will land in `G:/My Drive/Card Game Art/Pending Review/Batch 15/`, named by their target IDs from docs/art/batch15_nov12.csv.
- Check that folder at the start of each part. Once it has files, import them before continuing:
  - Approved_* folders as usual; old versions to Superseded;
  - wire each image to its target. The windows swap between day and freed-city lit; the banners and the lanterns/fireworks appear only after Primm; the easel portraits; the stalls, the orb, the statue and the mill sails (spinning); the locked packs; the item slots (inside the existing slot rect); the match table and the card back; the credits panorama behind the credits; Hesper and Wrinkles replace the code recolour (remove the stopgap); the mat replaces the tiling texture.
- Screenshot each image in game. Mark the CSV rows "In game".
- **Not in this batch:** the six world maps and the eight Gallery bestiary pictures. Leave those rows "To make".
- If the folder is still empty when Parts 1, 3 and 4 are done, keep working down Part 1's list and check again. Leave the import to the last 3 hours if needed.

## Part 3 — Late game
1. The inbox 11 (a) and (b) changes above, with tests.
2. Two of the late critic's other points:
   - the castle steps' wall-corner snag: walk every castle stair and corner with the driver;
   - the critic's smaller notes, S/M only.
3. A fresh no-context late-game critic replays the Capital → the castle → Primm → the ending → the credits → the postgame start, on an exported build with all of today's changes.
   - Its built-in player must not click covered cards: use the fixed driver.
   - If it can't beat Primm's Phase 3 in three tries, it may use `dev primm win` for that phase only. It reports the attempt and still plays the ending and credits for real.
   - It scores clarity, fun and polish against 6 / 4 / 6.
4. Fix its S/M items within the constraints, then a short re-score.

## Part 4 — Verify and build RC6
1. **The art director:** a fresh no-context art-director critic scores the same 113-shot set (the shots are taken after Batch 15, if it landed). Use **the Nov 12 after-critic's report as its calibration anchor** (give it 10 of last pass's after shots with their scores), so the before and after numbers share one scale.
2. All test shards green.
3. **The export:**
   - wait for ≥3 GB free;
   - `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6`;
   - the exported release smoke;
   - the three `play_exported.sh` checks with 0 SCRIPT ERROR;
   - docs/release/rc6_notes.md.
   - If the export is stopped for memory, say so at the top of the report with the exact command for the owner.
4. **docs/overnight_report.md**, with at the top:
   - the art scores (anchored) per group;
   - Part 1 done / not done;
   - the Batch 15 import table;
   - the late-game score;
   - FPS and size;
   - where RC6 is;
   - **the final release checklist for 1.0.0** (updated from Nov 11's, including the donation link, version, export, smoke, the itch upload and the flip to Public).
5. Update docs/HANDOFF.md and docs/release/post_1_0_backlog.md (the remaining art rows, the maps, the Gallery bestiary, the small-plan prompt templates).
6. Commit and push. No public upload.
