# Handover - The Wayward Path (final, Nov 9 2026)

For the owner after the 1.0 release: a $20 Claude plan and a $20 ChatGPT plan, light sessions, no all-night runs, a smaller context.
Everything below is written so that one short session does one thing and finishes it. The steps in section 2 are the ones that were run on
Nov 9 for the 1.0.0-rc1 build (`docs/overnight_report.md`, "Fable Nov 9").

## 1. Where things are

Repo: `C:\Dev\Deckbuilder-rpg` (GitHub `Aglowatz/Deckbuilder-rpg`, branch `main`). Engine: Godot 4.7.2 at `C:\Tools\Godot\`.
Conventions every session must follow are in `CLAUDE.md` (static typing, `core/` = rules without scenes, `ui/` + `world/` = scenes, asset
policy, tests).

| Folder | What lives there |
|---|---|
| `app/` | autoloads: `game_session.gd` (Session: the whole save state and game flow), `settings.gd`, `game_log.gd`, `save_system.gd`, `dev_actions.gd` (F10 Dev Menu) |
| `core/` | pure rules: `game/` (battle engine), `ai/`, `data/` (catalogs, conditions), `quests/` (all quest definitions), `zone/` (zone defs), `dungeon/`, `sim/` (balance sims, `level_hints.gd`) |
| `ui/` | screens: `battle/`, `town/` (Deck Station, Character page, dialogue), `screens/` (title, settings, credits, pause), `dungeon/`, `minimap/` |
| `world/` | the walkable 3D places: `town_scene.gd` (Crosspath), `zone/zone_scene.gd` + one folder per zone, `capital/`, `starting_area_scene.gd` |
| `data/` | cards (`data/cards/*.tres`, resources in `data/tokens/`), story text (`data/story/*.tres`), NPCs (`data/npcs/npcs.json`), dungeons, items, credits |
| `assets/art/` | every image the game shows (cards, portraits, sprites, keyart, boards, maps, ui, icons, zone_kits) |
| `assets/audio/` | music, stings, sound effects |
| `tools/` | importers, smokes, bots, sims, the export (`*.sh` wrappers; `*.gd` scripts; `*.js` / `*.py` helpers) |
| `tests/` | GUT tests (about 2,900) |
| `docs/` | design docs, reports (`overnight_report.md`), inbox (`overnight_inbox.md`), release kit (`docs/release/`), reviews (`docs/review/`) |
| `builds/` | the exported builds and zips (not in git); `builds/_testpack/` the test pack for exported-build runs |

Key files to know by name: `core/quests/quest_definitions.gd` (quests), `core/zone/<zone>_zone.gd` (a zone's NPCs, spots, quests),
`app/game_session.gd` (flow), `data/credits/credits.cfg` (creator name + donation link), `project.godot` (`config/version`), `CHANGELOG.md`.

## 2. Play, test, export, check, upload (as run on Nov 9)

**Play:** open the project in Godot (`C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`, Import `project.godot`) and press F5. F10 opens the
Dev Menu (teleport, level, gold, auto-win). One Godot at a time on this PC (7.4 GB RAM): close the editor before any script below.

**Light test subset (5-10 minutes):**
1. `bash tools/run_tests.sh --only=tests/core --size=12` (rules, quests, saves).
2. `bash tools/quest_audit.sh` (every quest still completable on paper).
3. If you touched a screen: `bash tools/gut_one.sh tests/ui/<the screen's test>.gd`.
The full suite: `bash tools/run_tests.sh --only=tests --size=12` (about 10 minutes; `--from=N` resumes after a stop; logs `_logs/gut/`).
The runner waits for memory by itself (Nov 11): before each shard it checks the free RAM and waits until at least `--min-free=MB`
(default 900 MB; a 12-file shard holds 400-630 MB) is free, polling every 10 s for up to `--wait-max=SEC` (default 600). A shard it
could not start in that time is skipped and listed under "Crashed shards" with the `--from=N` to rerun it. `--min-free=0` turns the wait
off. If Claude Code's own low-memory guard still stops the run, close Chrome / ChatGPT and rerun with `--from=N`.

**Export (Windows):** close Godot, then `bash tools/export_windows.sh <version>` in the foreground (about 4 minutes; it wants 2 GB of free RAM
and 2.5 GB of disk; `EXPORT_LOW_MEMORY_OK=1` runs it with less, as on Nov 9 with 1.4 GB free). It imports, exports with the shader baker,
checks the exe and the pack (every MD5, baked shaders, size), zips with CRC checks and only then replaces `builds/_export/` and
`builds/TheWaywardPath-v<version>-windows.zip`. "EXPORT STOPPED" means nothing was replaced. Before a release: set `config/version` in
`project.godot` (1.0.0-rc1 today; `1.0.0` for the release), add a `CHANGELOG.md` entry, then export.

**Check the exported build (as a player, not the editor):**
1. `bash tools/run_release_smoke_exported.sh` - the release smoke on `builds/_export/TheWaywardPath.pck` (17 checks, about a minute; look for `PASSED`).
2. `bash tools/export_test_pack.sh` once per build (the release content plus `tools/`, so the play driver can run on exported resources), then
   `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt rc1_a 480` (and `_b`, `_c`): title, Credits, a new game, Crosspath, a
   shop, the Deck Station, the Wardrobe, the Card Packs page, a battle, the pause menu, a settings change, Copy log, the save slots; `_b` seeds
   the settings a run left (`SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_rc1_a.cfg`) to prove they survive a restart; `_c` forces
   the Low-end preset (quality 0). Shots land in `_screenshots/exported/`.
3. The real `.exe`, fresh install: move `%APPDATA%\Deckbuilder-RPG` aside by hand (`mv`), then
   `powershell -ExecutionPolicy Bypass -File tools/exe_drive.ps1 -Exe builds/_export/TheWaywardPath.exe -Script docs/review/play_scripts/exe_b.txt -Out _screenshots/exe/b`
   (then `exe_c.txt`, `exe_d.txt`): real clicks and key presses with screen captures - first launch, New Game, the intro and Path choice, the pause
   menu, Reduce motion, a manual save, Quit Game; the next launches check Continue, the saved setting, Load Game and the Credits. Move the real
   user folder back afterwards. (Clicks are capture coordinates: the 1600x900 game plus an 8 px frame and a 31 px title bar; `press ESC` sends a
   real scan code - SendKeys' Escape is ignored by the game.)
4. A fresh critic on the exported build: give a `general-purpose` agent only `docs/review/critic_rc1_brief.md`; run nothing that starts Godot
   while it plays; its report lands in `docs/review/critic_rc1/report.md`. For later content (Nov 10): `docs/review/critic_mid_brief.md` (a
   level-14 snapshot, a Path zone and its main dungeon) and `docs/review/critic_late_brief.md` (the Capital, Primm's Castle with the real Primm
   fight, the ending, the postgame); they `dev load` snapshots from `%APPDATA%\Deckbuilder-RPG\dev_saves` (`bot_refusemancer_enter_gourmand`,
   `c13cap`, `c13castle`, `c13end`, `c13post`), so keep that folder.
5. **What is in the pack:** `node tools/verify_pck.js builds/_export/TheWaywardPath.pck --no-md5 --largest=20` (the 20 largest entries;
   `--tsv=<file>` writes every entry). Unused files: `node tools/reference_graph.js --list`; a file found unused goes in
   `tools/export_unused.json` (the export leaves it out; the source stays). Size rules: `docs/build_size_policy.md`.

**Upload to itch.io:** step by step in `docs/release/itch_upload.md` (page, "$0 or donate", text, the AI disclosure field, the zip, screenshots,
Draft/Restricted until release, the Support link, playtesters, the public flip, butler). Page text, tags, cover advice: `docs/release/itch_page/`.
Playtester notes: `docs/release/rc1_notes.md`.

## 3. The art pipeline

1. **Make the image in ChatGPT** from a row of the art list (`docs/art/art_audit_nov9.csv`, verdict REDO; the next batch goes in
   `docs/art/batch15_*.csv`). Attach the reference images the row names (a character's portrait, the zone's existing art). Style lock: painted
   cozy fantasy, warm light, the art bible's palette per Path (`docs/art/art_bible.md`); characters keep their species (Flex is a lion, Dex a
   ferret, Sable a fox, Tonic a frog, Fenwick a magpie, Pip a mouse, Brannoch a bear...). No red cross on white anywhere (the protected emblem).
2. **Name it** exactly as the row's id (e.g. `V-SABLE_PLEASED.png`, `STORY-PRIMM-P1.png`); a second try is `-ALT` or `-v2`.
3. **Put it in `Pending Review/Batch N/`** on Drive, then file it with a copy of `tools/batch14_move.js` (edit the batch name and the folder rules:
   `NPC-`/`V-` portraits -> Approved_Characters, `SPR-` -> Approved_Sprites, cards -> Approved, `STORY-` -> Approved_KeyArt, `BST-` -> Approved_Bestiary,
   `ICON-` -> Approved_Icons, `UI-`/`MG-` -> Approved_UI, kit pieces -> Approved_ZoneKits/<Zone>); `node tools/batchNN_move.js` is a dry run,
   `--apply` moves (old files go to Drive `Superseded/`, local copies to `_art_source/superseded_batchNN/`).
4. **Import it:** `bash tools/import_<kind>.sh` one at a time (`import_portraits.sh`, `import_npc_sprites.sh` then
   `Godot --headless --path . -s res://tools/sprite_normals.gd -- --only=<KEY> --force=true`, `import_art.sh` for cards, `import_key_art.sh`,
   `import_bestiary.sh`, `import_icons.sh`, `import_zone_kit.sh <zone>`). Importers only copy from Drive; they never delete or rename there.
   Known quirks: the portrait importer re-adds the opaque `NPC-PLAYER.webp` (git checkout it and its manifest row); the NPC sprite importer rewrites
   `assets/art/world_test/sprites/manifest.json` with churn (splice only the new key into HEAD's text, keep `cloak_hue` / `head`); the status writer can
   drop sections of `docs/art/art_status.md` (restore them from HEAD); the "Identifier not found: Session" compile error in a headless run is noise.
5. **Check it in game:** portraits `bash tools/dialogue_shots.sh res://scenes/town.tscn b15 "portrait:V-SABLE~pleased,..."`; cards
   `bash tools/shot.sh res://scenes/dev/card_gallery.tscn cards --ids=A,B` and `bash tools/shot.sh res://scenes/battle.tscn hand --hand=A,B --zone=beefcake --wait=7`;
   stills `bash tools/story_still_shots.sh 1600x900 --ids=STORY-X` or the real cutscene
   `bash tools/shot.sh res://scenes/dungeon_map.tscn x --dungeon=D-PC --open=cutscene --scene_id=primm_p1 --wait=5`; a bestiary page
   `bash tools/shot.sh res://scenes/town.tscn x --open=bestiary:Antechamber_Sentry --wait=4`; shops `--open=item_vendor`. Mark the CSV rows
   "In game", run the light tests, commit.
6. A redone portrait variant needs no code change any more (`Portraits.HELD_EXPRESSIONS` is empty). Hesper's redo landed with Batch 15 (Nov 13) and
   the in-code recolour (`art_patches.gd`) is gone.

## 4. The music pipeline

Scores are Python in `tools/music/scores/`; `tools/music/build.py` renders them with FluidSynth + FluidR3_GM, `deliver.py` copies the renders
into the game, `bash tools/import_audio.sh` imports. Docs: `docs/audio/music_toolchain.md`, `docs/audio/score_bible.md`. A small change ("make
the town theme 10 s longer"): edit the score file, build that one cue, listen, deliver, import, commit. Music stays at Vorbis q6 by the designer's
decision (`docs/build_size_policy.md`).

## 5. The dialogue workflow

1. `node tools/export_dialogue.js` writes a CSV of every line in story order (ID, area, speaker, when, current line, new line).
2. Open it in Google Sheets; write changes in "New line" (leave the rest alone).
3. Download as CSV into `docs/dialogue/`, then `node tools/apply_dialogue_pass.js --csv=docs/dialogue/<file>.csv` (dry run report), then the
   same with `--apply`. It checks tokens, length and that the line fits the box. `--revert` puts a CSV's changes back. Two lines are pinned by
   tests on purpose (the Rescuer's "which Path resonates within you?" and Flex's "it was not the part that matters").

**The Nov 13 dialogue rewrite** (1,245 lines; story in `docs/writing/story_bible_v2.md`, voices in `docs/writing/voices.md`): the scene
sources are `docs/dialogue/rewrite_nov13/t*.txt`. To change lines, edit a scene file, rebuild its CSV with
`node tools/dialogue_scene_build.js --base=docs/dialogue/rewrite_nov13_base.csv --out=<csv> --ids=<ids.txt> <scene files>` and apply it as
above. To put a group back: `node tools/apply_dialogue_pass.js --revert=docs/dialogue/rewrite_nov13_t<N>[_<group>]_ids.txt`. The current
workbook for playtesters is `docs/dialogue/playtesters_nov13.xlsx` (`python tools/build_playtester_workbook.py` rebuilds it). A returned
Nov 9 workbook still imports: rows on lines rewritten on Nov 13 are listed as "Base changed tonight" and not applied.

**Playtesters' rewrites (the workbook `docs/dialogue/playtesters_nov9.xlsx`, Nov 10):** save every returned copy (any names, e.g.
`docs/dialogue/returned/alice.xlsx`), then three commands from the repo folder:

```
python tools/import_playtester_dialogue.py docs/dialogue/returned/*.xlsx
node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv
node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv --apply
```

1. **Convert** reads the "Dialogue" tab of each file (ID in B, New line in H, Notes in M, Reviewer in N; found by header name), skips empty New
   lines, and checks each rewrite against the game's current text: the ID exists, every `{token}`, `[tag]` and `%s` is kept, one line, at most
   240 characters (90 for barks). Rows added, deleted or sorted are reported (matching is by ID, never by row). Two testers who rewrote the
   same line differently are a **conflict**: both versions are listed, neither goes in. Output: `playtesters_nov9_merged.csv` (accepted rows
   only) and `playtesters_nov9_merged_report.md` (accepted / rejected with the reason / conflicts / sheet structure). Read the report.
2. **Dry run**: the usual importer report (`docs/dialogue/playtesters_nov9_merged/apply_report_dry_run.md`), including the fits-the-box check
   (it runs Godot; close the game first).
3. **Apply** writes the game files. **Undo:** the same command with `--revert` (all of it) or `--revert=ids.txt` (some lines). To settle a
   conflict, copy the line you choose into a CSV with columns `id,new_text` and run `... --merge=<that file> --apply`. Then run the tests.
   Options: `--out=<csv>` for another output name; `--template=<xlsx>` if the original workbook moved. No extra Python packages needed.

## 6. Small, safe prompts for a $20 plan

Rules of thumb: one task per session; name the files; say what "done" means; ask for the light tests only; ask it to commit when green.
Start every prompt with: *"Repo C:\Dev\Deckbuilder-rpg, Godot 4.7.2. Read CLAUDE.md first. One Godot at a time. Don't export unless I ask."*

1. **Fix a bug:** "Bug: <what you saw, where, how to repeat it>. Find the cause (start in <file if known>), fix it with the smallest change,
   add a GUT test that fails before the fix, run that test file and `tests/core`, commit."
2. **Tweak a card:** "Card <ID> (<name>) in data/cards/<ID>.tres: change <cost/stats/text> to <new>. Keep rules text and effect in step
   (core/game). Run tests/core/game and tests/core/data, commit."
3. **Add a quest line:** "Add a side quest in <zone>: given by <NPC> (spot <id>), steps: <1..n>, reward <gold/item>. Follow the pattern of
   <an existing quest id> in core/quests/zone_quest_definitions.gd, put its lines in the zone's story file, run `bash tools/quest_audit.sh`
   and tests/core/quests, commit."
4. **Import one image:** "I put <ID>.png in Drive Approved_<kind>. Import it with tools/import_<kind>.sh, check it shows where it should
   (<place>), take one screenshot with tools/shot.sh, run the test for that importer, commit."
5. **Edit dialogue:** "Apply docs/dialogue/<file>.csv with tools/apply_dialogue_pass.js (dry run first, then --apply), show me the report, commit."
6. **Make a release build:** "Set config/version to <x.y.z> in project.godot, add a CHANGELOG entry, run the full test suite in shards, then
   `bash tools/export_windows.sh` in the foreground, then `bash tools/run_release_smoke_exported.sh`, and tell me the zip's path and size.
   Don't change anything else."

## 6b. What the Nov 12 fix pass added (read before touching these)

Brief `docs/prompts/fable_nov12_fixes.md`, report at the top of `docs/overnight_report.md`, inbox "Fable Nov 12c".

- **Dungeon pop-ups** are all built on `ui/dungeon/node_card.gd` (`NodeCard`): the shrine, the well and deck challenges
  (`challenge_screen.gd`), events and rescues, treasure, and the pre-fight rules panel (`ui/widgets/rules_brief.gd`, used by the dungeon
  maps, the arena, Shiro and the Old Well). A new kind of room: `NodeCard.make(kind, title)`, then `flavour`, `effect`, `hp_preview`,
  `chip`, `button`. Shots of every type: `--open=challenge|shrine|event|treasure|brief` on `scenes/dungeon_map.tscn` through
  `tools/shot.sh` (add `--accept=1` for the well after the card is given, `--set=text_dialogue:3` for Large text).
- **The Hollow Well** is `ChallengeData.Kind.RANDOM_SACRIFICE` (`ChallengeResolver.offer_block` says why it is closed). A run hands its
  deck back with `DungeonRun.deck_after_run()`: nothing a dungeon takes is permanent.
- **The Crease** is `world/capital/capital_crease.gd` (the cavern shell, shown only while the hero is in the Crease). The layout's props
  and anchors are still in `capital_layout.gd` (`_crease`). **The Capital's rim** carries `capital_rim_ruins.gd`.
- **A cached KitMesh needs its card materials back:** after `KitMesh.restore`, call `resolve_missing(CapitalKit.resolve_slot)` (or use
  `fill_cached_set` with the resolver). Forgetting it draws every painted card as a flat grey rectangle from the second visit on.
- **The occlusion fader** keeps a faded group until it is back at zero; a long wall names its body with the meta `occlusion_box` (and
  `occlusion_near`) so its towers do not count. The driver command `meshscan <x> <z> [radius]` names what a screenshot shows.
- **Primm:** `Session.retry_primm_fight` (the defeat screen's "Fight Primm again").
- **The play-script driver saves the camera angle and zoom into your settings** (`cam N`, the pad smoke's zoom). After a shot run, check
  Settings > Display > Camera angle (the shot scripts leave it on Low) and the zoom.

## 7. Known issues and the post-1.0 backlog

`docs/release/post_1_0_backlog.md`: playtester feedback intake, the known issues at 1.0.0-rc1, the remaining art REDOs, nice-to-haves and what
a Steam release would still need (Steamworks, achievements from feats, cloud saves, store assets).

## 8. Backups

- **GitHub:** every session ends with `git push` (the repo is the source of truth; large art stays in Drive and in the repo's `assets/`).
- **Drive copy, one line** (Git Bash in the repo; a zip of the committed tree without `.godot/`, `builds/`, `_logs/`, `_screenshots/`):

  ```
  cd /c/Dev/Deckbuilder-rpg && git archive --format=zip -o "/g/My Drive/Card Game Art/Backups/wayward_$(date +%Y%m%d).zip" HEAD
  ```

  (make the `Backups` folder once). Keep the last 4. Do it once a week and before any big import.
- The Approved_* Drive folders are the art masters; never delete from them (old versions go to `Superseded/`).
- The exported zips in `builds/` are not in git: copy the released zip to Drive next to the backups.
