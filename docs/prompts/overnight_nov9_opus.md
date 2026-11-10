# Overnight Nov 9-10 (Opus) — release-candidate hardening

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0 target is a free itch.io release this week. The owner is asleep.
Read docs/overnight_report.md (the Fable Nov 9 pass) first. Work through the parts in order (priority order). Log questions in
docs/overnight_inbox.md under "Overnight Nov 9-10". Tag `pre-overnight-nov9b` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- Claude Code's low-memory reaper is off for this run, so keep memory safe yourself:
  - ONE Godot process at a time; kill strays before each job;
  - no sub-agents while Godot runs;
  - stop a job cleanly if free memory drops under ~800 MB, then move on.
- Tests: memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N`).
- Screenshots go to docs/overnight_shots/nov10/.
- Commit and push after each part. No public upload.
- Don't replace art files.
- Keep docs/HANDOFF.md accurate for anything you change.

## Part 0 — Finish the Fable pass
Anything docs/prompts/fable_nov9.md lists that its report marks as not done (import, RC1 export, exported-build checks, the critic's quick fixes, the itch kit, the trailer, the handover): finish it first.

## Part 1 — Fix the RC1 critic's findings
Fix every item from the Fable pass's fresh-eyes critic (top 10 plus any others it logged) that is S or M effort. List the L items with a plan.

## Part 2 — Exported-build check of the mid and late game
The RC1 critic covered the first hour. Now, on the **exported** build, with snapshots to jump ahead:
1. One fresh critic (no context) plays 45 minutes of a midgame zone, including a main dungeon.
2. Another plays 45 minutes of the Capital, Primm's castle (with the real Primm fight), the ending and the start of the postgame.

Each scores clarity, fun, polish and anything broken or obviously AI-made, and lists its top 10. Fix the S/M items; log the rest.

## Part 3 — Tool for the playtesters' dialogue rewrites (they're editing docs/dialogue/playtesters_nov9.xlsx now)
Write `tools/import_playtester_dialogue.py` (or .js, matching the repo's tools). It must:
- read one or more returned .xlsx files (the "Dialogue" tab: the ID in column B, the New line in column H, Notes in M, Reviewer in N);
- ignore empty New lines;
- validate each row:
  - the ID exists;
  - every `{token}` and `[tag]` from the current line is kept;
  - the length limit holds (240, or 90 for barks);
  - no rows were added or reordered (match by ID, not by position);
- write a clean CSV in the format `apply_dialogue_pass.js` expects, plus a report listing:
  - accepted lines;
  - rejected lines with the reason;
  - conflicts, where two testers rewrote the same line: show both and pick neither; the owner decides.

Then:
- Document the 3-command workflow in docs/HANDOFF.md (convert, dry run, apply / revert).
- Test it on a copy of the workbook with ~10 fake edits (valid, token-dropped, too long and conflicting), then delete the test files.

## Part 4 — Accessibility and controls
1. **Text size:** a Settings option (Normal / Large / Larger) that scales dialogue, tooltips and card text. Check that nothing breaks at 1280x720 on Large.
2. **A full controller pass:** reach and use every screen with a gamepad only, from the title through a battle, the shops, the Deck Station, the Wardrobe, the Card Packs page, the minigames, the map and the settings. Fix dead ends.
3. Check that **key rebinding** works and is saved, with no unbindable essential action.

## Part 5 — Performance and size
1. The Capital's later-visit load (about 7 s): finish caching whatever is still rebuilt on each visit. Report before and after.
2. A Low-end check on the exported build: a walk through Crosspath, the Capital and a battle, with FPS and memory numbers.
3. **Download size:** list the 20 largest files in the export and remove anything unused (dead assets, superseded art still packed, test files). Check against docs/build_size_policy.md and report the final zip size.

## Part 6 — RC2
If Parts 1-5 changed anything:
- Export `bash tools/export_windows.sh 1.0.0-rc2` and run the release smoke.
- Repeat the short exported-build checklist from fable_nov9 Part 2.
- Write docs/release/rc2_notes.md.
- Put the zip next to RC1, and give the path in the report.

## Finish
- All test shards green.
- docs/overnight_report.md, with at the top:
  - what was fixed (with screenshots);
  - the critics' top 10s;
  - how the dialogue tool works, in plain steps;
  - the accessibility and controller results;
  - the size and performance numbers;
  - where RC2 is;
  - anything the owner must do or decide before the public release.
- Commit and push. No public upload.
