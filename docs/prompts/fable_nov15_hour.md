# Fable Nov 15 (about 1 hour): verify, the owner's answers, small fixes

Repo: C:\Dev\Deckbuilder-rpg. Read the top of docs/overnight_report.md and docs/overnight_inbox.md ("Fable Nov 14" and "Fable Nov 15").
**Time box: about an hour. Stop adding work at 50 minutes and finish Part 5.** Log questions under "Fable Nov 15b". Tag `pre-fable-nov15b`.

## House rules
- ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`.
- Commit and push after each part.
- Shots go in docs/overnight_shots/nov15b/.
- No difficulty setting, no battle-board layout changes, Primm's fight unchanged, no public upload.

## Part 1 — The owner's answers to inbox "Fable Nov 15" and "Fable Nov 14" (apply)
- **Keep as built:**
  - Nov 15 items 1 ("Rift-Empowered"), 2 (the roamer "Before the fight" card), 3 ("Caught Unprepared"), 5, 6, 7 and 8;
  - Nov 14 items 2 (Sergeant Scuff), 3 (Maren's study is what the Lab was built from; she never forged a bar), 4, 5, 6, 8, 9, 11 and 12.
- **Nov 15 item 4 (Primm's rule shows twice):** keep the phase badges and **remove the duplicate line** from the gold rule panel under the HUD in his fight, so each rule shows once. Change nothing else in his fight.
- **Nov 14 item 7:** the Gate Plaza and palace-approach shaft signs keep the purple travel swirl.

## Part 2 — The Verdant Dump: check against the owner's screenshots
Last pass guessed the "floating door" and the "walk-through block" without screenshots. The owner's shots are now in `docs/overnight_shots/nov15b/`:
- `ref_dump_floating_door.png`: two **flat green slabs** standing near the giant pink-mushroom tree, beside the purple rock pillars and the market. One of them is the "floating door";
- `ref_dump_wooden_block.png`: a **large brown wooden platform/slab** by the stream bridge and the conveyor, which you can walk through;
- `ref_dump_top_right.png`: the top-right area with the heart tree.

**What to do:**
1. Find each object from the screenshot (match the camera, use `tools/heap_odd_probe.gd`).
2. If last pass's removals (the hay bale, the hollow log) were **not** these, remove these too and dress the spots naturally from the Dump kit.
3. Re-check that the top-right tree wall blocks walking in from the middle (walk-grid probe) and that the treasure field reads clearly.
4. Shoot each camera before and after.

## Part 3 — The walk smokes not re-run last pass
Run the Gainlands, the Endless Buffet and the Verdant Dump walk smokes (their ruler statues changed in Part 3 of the Nov 15 pass). Fix anything they catch. Take a screenshot of each zone's ruler statue, standing and toppled.

## Part 4 — UI scale 130% (if time is left)
The Wardrobe, the Card Packs page and the Deck Station crop at the right and bottom at 130% UI scale.
- Make them fit at 115% and 130%: put their fixed-size layouts on containers or anchors that respect the scale. Don't change how they look at 100%.
- If a screen can't be done well in the time, cap the UI scale on that screen to the largest size that fits, and log it.
- Take screenshots at 100%, 115% and 130%.

## Part 5 — Tests, build, report
1. All test shards green. If the guard stops a background run, finish in the foreground with `--from=N --to=K`.
2. **If anything changed**, re-export 1.0.0:
   - wait up to 10 minutes for at least 2.2 GB free RAM;
   - in the foreground, run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks.
3. A short report at the top of docs/overnight_report.md: what changed, with shots, and where the zip is.
4. Commit and push. No public upload.
