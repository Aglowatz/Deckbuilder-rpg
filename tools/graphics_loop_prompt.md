# Graphics loop run

You are one scheduled, non-interactive run of the overnight graphics-improvement loop for the Godot deckbuilder RPG in this repo (`C:\Dev\Deckbuilder-rpg`, branch `main`). Nobody is watching: never ask questions, make sensible choices, keep going until you hit the usage limit or every task is done. Another run will take over after you stop, so leave the repo clean and the plan file current.

## 1. Start-up (do these first, in order)

1. **Push first.** Run `git status -sb`. If the branch is ahead of `origin/main`, run `git push origin main`. On a network error retry up to 3 times (wait ~20 s between tries). If it is still offline, carry on working and push later (try again after each commit).
2. **Free memory.** This PC is low on memory. Kill leftover Godot processes before doing anything else (`taskkill //F //IM Godot_v4.7.2-stable_win64.exe`, `taskkill //F //IM Godot_v4.7.2-stable_win64_console.exe` in Bash). Only ONE Godot process may exist at a time; always let one finish (or kill it) before starting the next, and never leave one running when you stop. The `tools/area_shots.sh` and `tools/ui_shot.sh` scripts already kill leftovers first.
3. **Read:** `CLAUDE.md`, `docs/art/style_guide.md`, and `docs/art/graphics_loop.md` (the whole plan, including the scoring rubric and the HANDOFF NOTES at the bottom). Skim the newest Handoff entries carefully: they say what is half-finished and what went wrong last time.
4. If the working tree is dirty at start, look at `git status` and `git diff --stat`: it is probably unfinished work from the previous run on the task marked `[~]`. Continue it; do not discard it. If it is clearly broken junk, `git stash` it and note that in the Handoff notes.

## 2. The work loop

Repeat until the usage limit stops you or every task in `docs/art/graphics_loop.md` is checked:

1. **Pick the task.** If any task is marked `[~]` (in progress), resume it. Otherwise take the FIRST unchecked `[ ]` task in file order (global tasks G-xx first, then areas in the order written, then F-01/F-02).
2. **Mark it in progress** (`[ ]` to `[~]`) in `docs/art/graphics_loop.md` and commit that edit together with your first real change (or as a tiny commit) so a later run knows what you were doing.
3. **Take the BEFORE shots** with the task's area command (tag `before`) unless baseline/`before` shots for the same state already exist; VIEW them with the Read tool.
4. **Do the task** as described: small, focused changes in `world/`, `assets/shaders/`, `world/style/` or the area's builder. Match the surrounding code (static typing everywhere, `class_name`, comments as in neighbouring files, core/ vs ui/ split per CLAUDE.md). Prefer shared systems (style rig, presets, ScatterTool, decals) over one-off hacks so every area benefits.
5. **Verify with screenshots and the rubric** in the plan file: shoot the area from at least 3 angles (tag `after`), VIEW every image, score L/C/G/D/M/A/R/X from 1 to 10 honestly (the rubric table defines 7 and 10). If any score is below 7, write the critique, fix it and re-shoot as `iter2`, then `iter3` (maximum 3 iterations). Then record the scores, the before and after screenshot paths and one line about what changed in the task's `Result:` line, and check the box `[x]`. If a score is still below 7 after 3 iterations, check it off with the honest scores and add a "Follow-up: ..." task at the end of that area's list (or under FOLLOW-UP TASKS) and mention it in the Handoff notes.
6. **Keep 60 fps on Medium.** After finishing the last task of an area (the `-6 Final polish` task), and after any task that adds shaders, particles, lights or many meshes, run `bash tools/fps.sh <area scene> 1` for the busiest area you touched (the town is the heaviest). If Medium drops below 60, fix it before moving on (reduce counts, instancing, quality-scale the feature) and record the numbers in the task result.
7. **Run all tests, then commit and push.** Run `bash tools/run_tests.sh` (GUT, including the compile-every-script test) before EVERY commit; never commit with failing tests or a script that does not compile. If tests fail because of your change, fix it; if they fail for an unrelated pre-existing reason, say so in the Handoff notes and do not commit the breakage. Commit with a clear message (`Graphics loop <task id>: <what>`) ending with the attribution line required by the environment, then `git push origin main` (retry on network errors; if offline, keep committing locally and push at the next chance).
8. Copy the best before/after pair for finished areas into `docs/art/screens/graphics_loop/<area>_before.png` and `_after.png` (small PNGs, committed).
9. Go back to step 1.

## 3. Rules

- **Out of scope, do not touch:** card art, card frames and the card view (`ui/card/`), the card data pipeline (`data/source`, `data/cards`, `data/tokens`, `core/data/card_importer.gd`, `tools/import_*`), gameplay rules (`core/` rules, AI), balance (card numbers, AI values, decks). If a graphics change seems to need one of these, find another way or skip it and note it.
- **Assets:** free assets may be downloaded (Kenney, KayKit, Quaternius, Poly Pizza, Poly Haven, ambientCG, OpenGameArt and similar) following the CLAUDE.md Asset Policy: CC0 preferred, CC BY allowed with attribution, NEVER NC, ND or unclear licences. Download packs into `_asset_library/<pack>/` (git-ignored), view previews to confirm the style fits (low-poly toon, bright and charming), copy only the files actually used into `assets/` with the licence file, and log everything (name, author, URL, licence, date) in `CREDITS.md`. Mention newly added packs in the Handoff notes.
- **Screenshots:** always from a real windowed run via the tools (`tools/area_shots.sh`, `tools/ui_shot.sh`, `tools/shot.sh`); screenshots are git-ignored under `_screenshots/`. Never score without viewing the images.
- **Memory:** one Godot process at a time, closed after each screenshot set. No parallel Godot runs, no background Godot.
- **Time boxing:** if a task is huge, split it: finish a useful, committable slice, check off what is done, and add the remainder as a new task right after it. Never leave the project in a broken state at a commit.
- **Do not edit the scheduler, runner or this prompt** unless something in them is plainly broken (then fix and note it).
- Windows + Git Bash: use the Write tool for GDScript containing apostrophes (Bash heredocs with apostrophes can fail). There is no Python on this PC.

## 4. Before you stop (usage limit, or all tasks done)

1. Make sure nothing is half-edited without a commit: commit finished work (tests green) or stash/note unfinished work; a task that is not finished stays `[~]`.
2. Kill any Godot process you started.
3. Add a dated entry at the TOP of the Handoff notes table in `docs/art/graphics_loop.md`: what was done (task ids and scores), anything half-finished (which `[~]` task, what remains, which files), problems found (crashes, fps numbers, licence questions), and ideas for the next run. Commit and push that too.
4. **When every task is complete:** do the full review pass (task F-01): re-shoot every area from 3 angles, view and re-score; for every area scoring below 8 on any criterion add new tasks (same format, under FOLLOW-UP TASKS) and keep working through them. Then do F-02 (performance sign-off).
