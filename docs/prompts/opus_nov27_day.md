# Nov 27 day (a few hours): the bug soak, the Extra Pocket measured, the draft audit finished

Repo: C:\Dev\Deckbuilder-rpg. This run is on Opus and lasts a few hours. The owner may be playtesting, so if his Godot editor or game is open, run only what fits, or wait. Work without stopping to ask. Log questions under "Nov 27 day" in `docs/overnight_inbox.md` and take the safest choice.

Read first:
- the top of `docs/overnight_report.md` ("Nov 26 night"), especially "What's left".

Run `git status` and tag `pre-nov27`.

House rules are as in `docs/prompts/opus_nov26_day.md` (STOP_OVERNIGHT, one Godot at a time, `--min-free=1200`, sims batched at most 30 variants with a 20-minute limit, commit and push after each part, no public upload, the owner constraints, a test for every fix). Shots go in `docs/overnight_shots/nov27/`; sims go in `docs/design/sim/nov27/`.

**Change no balance numbers.** The Nov 26 night proposals and decisions wait for the owner, and the postgame stays as it is. Bugs, softlocks, script errors and unclear text are fixed, each with a test.

## Part A — The bug soak (Nov 26 night's Part E)
1. **Write a random-play bot** that drives the game through every screen and mode with random but valid choices:
   - the title, new game and load;
   - the world;
   - the Shuffle House's four modes, the Shuffled Halls and the Puzzle Tables;
   - zone drafts;
   - both deck builders, the shops, Auntie Alembic, Pip and the Bestiary;
   - dungeons, events and fights;
   - saving and loading mid-way.
2. **Run several seeds** in batches of at most 30 minutes, one process at a time, about 2 hours in total. Use the 1280x720 and 1920x1080 window sizes.
3. **Catch:**
   - script errors and softlocks (no valid input, a screen that never closes);
   - UI off-screen or overlapping, and text running out of its box;
   - missing or placeholder art (magenta, the Godot icon);
   - saves that don't load back the same.
4. **Fix each problem with a test.** Keep the seeds, logs and the first frame of each problem in `docs/overnight_shots/nov27/soak/`. List what you couldn't fix.
5. Commit the bot (`tools/soak_bot.*`) so it can be run again before release.

## Part B — Measure the Extra Pocket
Run `tools/draft_sim.gd --what=pocket` and a main-game version: paired runs with and without the Pocket, with burn items and with heal items, in drafts, the zone dungeons and the postgame. Split the work into batches that fit the 20-minute limit. Report the win rate change and whether it's a must-take or breaks any fight. Add a **proposal** if needed; don't apply it.

## Part C — Finish the draft audit
Run what Nov 26 night didn't reach:
- the two three-Path Classic sets;
- the four High Rollers pairs;
- High Rollers with three Paths.

Add them to `docs/design/sim/nov26n/draft_balance.md`. Note any change to its findings.

## Part D — Checks, build, report
1. **Tests:** the test shards that cover what changed (all of them if many fixes landed), in small groups; the draft smoke; the walk smokes; the probes. Run the story bots one after another if anything in the world, quests or dungeons changed.
2. **Export 1.0.0 only if the game changed:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`, the exported smoke and the three `play_exported.sh` checks. Godot must be closed. If the owner's is open, skip the export and say so.
3. **`docs/overnight_report.md`,** at the top, under "Nov 27 day":
   - the bugs found and fixed, and what's left;
   - the Pocket's numbers;
   - the finished draft audit;
   - the zip, if exported;
   - any new decisions (at most 4, each with a recommendation).
4. Commit and push. No public upload.

If time runs short, finish the part in hand, commit and write the report. Part A comes first.
