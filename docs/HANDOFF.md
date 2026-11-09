# Handover - The Wayward Path (draft Nov 9, to be finalised Nov 11)

For the owner after Nov 12: a $20 Claude plan and a $20 ChatGPT plan, light sessions, no all-night runs, a smaller context. Everything below
is written so that one short session does one thing and finishes it.

## 1. Where things are

Repo: `C:\Dev\Deckbuilder-rpg` (GitHub `Aglowatz/Deckbuilder-rpg`, branch `main`). Engine: Godot 4.7.2 at `C:\Tools\Godot\`.
Conventions every session must follow are in `CLAUDE.md` (static typing, `core/` = rules without scenes, `ui/` + `world/` = scenes, asset
policy, tests).

| Folder | What lives there |
|---|---|
| `app/` | autoloads: `game_session.gd` (Session: the whole save state and game flow), `settings.gd`, `game_log.gd`, `save_system.gd`, `dev_actions.gd` (F10 Dev Menu) |
| `core/` | pure rules: `game/` (battle engine), `ai/`, `data/` (catalogs, conditions), `quests/` (all quest definitions), `zone/` (zone defs), `dungeon/`, `sim/` (balance sims) |
| `ui/` | screens: `battle/`, `town/` (Deck Station, Character page, dialogue), `screens/` (title, settings, credits, pause), `dungeon/` |
| `world/` | the walkable 3D places: `town_scene.gd` (Crosspath), `zone/zone_scene.gd` + one folder per zone, `capital/` |
| `data/` | cards (`data/cards/*.tres`), story text (`data/story/*.tres`), NPCs (`data/npcs/npcs.json`), dungeons, items, credits |
| `assets/art/` | every image the game shows (cards, portraits, sprites, keyart, boards, maps, ui, icons, zone_kits) |
| `assets/audio/` | music, stings, sound effects |
| `tools/` | importers, smokes, bots, sims (`*.sh` wrappers) |
| `tests/` | GUT tests (about 2,900) |
| `docs/` | design docs, reports (`overnight_report.md`), inbox (`overnight_inbox.md`), release kit (`docs/release/`) |

Key files to know by name: `core/quests/quest_definitions.gd` (quests), `core/zone/<zone>_zone.gd` (a zone's NPCs, spots, quests),
`app/game_session.gd` (flow), `data/credits/credits.cfg` (creator name + donation link), `project.godot` (`config/version`).

## 2. Play, test, export, upload

**Play:** open the project in Godot (`C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`, Import `project.godot`) and press F5. F10 opens the
Dev Menu (teleport, level, gold, auto-win).

**Light test subset (5-10 minutes, one Godot at a time):**
1. `bash tools/run_tests.sh --only=tests/core --size=12` (rules, quests, saves).
2. `bash tools/quest_audit.sh` (every quest still completable on paper).
3. If you touched a screen: `bash tools/run_tests.sh --only=tests/ui/<the screen's test>`.
The full suite: `bash tools/run_tests.sh --only=tests --size=12` (about 10 minutes on this PC; use `--from=N` to resume after a stop).

**Export (Windows):** close Godot, then `bash tools/export_windows.sh` (about 4 minutes, needs ~2 GB free RAM and ~3 GB free disk). It
builds, verifies and zips to `builds/TheWaywardPath-v<version>-windows.zip`. Before a release: set `config/version` in `project.godot`
(e.g. `1.0.0`) and add a line to `CHANGELOG.md`.

**Upload to itch.io:**
- *Web uploader (simplest):* itch.io > Dashboard > your project > Edit > Uploads > "Upload files" > the zip > tick "Windows" > Save.
- *butler (faster updates):* download butler from itch.io/docs/butler, run `butler login` once, then
  `butler push builds/TheWaywardPath-v1.0.0-windows.zip <your-itch-name>/the-wayward-path:windows --userversion 1.0.0`.
  butler only uploads the changed parts next time.
- Page text, tags, cover advice and the AI disclosure: `docs/release/itch_page/`.

## 3. The art pipeline

1. **Make the image in ChatGPT** from a row of the art list (the latest: the Batch 14 list in `docs/art/art_audit_nov9.md` and its CSV).
   Attach the reference images the row names (a character's portrait, the zone's existing art). Style lock: painted cozy fantasy, warm
   light, the art bible's palette per Path (`docs/art/art_bible.md`); characters keep their species (Flex is a lion, Dex a ferret, Sable a
   fox, Tonic a frog, Brannoch a bear...).
2. **Name it** exactly as the row's id (e.g. `V-SABLE_PLEASED.png`, `STORY-PRIMM-P1.png`); a second try is `-v2`.
3. **Put it in the Drive folder** for its kind: `Approved_Characters` (portraits), `Approved_Sprites`, `Approved_Cards`, `Approved_KeyArt`
   (stills, loading, logo), `Approved_Battleboards`, `Approved_Maps`, `Approved_UI`, `Approved_Icons`, `Approved_ZoneKits/<Zone>`,
   `Approved_EnvKit`.
4. **Import it:** `bash tools/import_<kind>.sh` (e.g. `import_portraits.sh`, `import_cards.sh`, `import_key_art.sh`, `import_zone_kit.sh <zone>`).
   Importers only copy from Drive; they never delete or rename there.
5. **Check it** in game (or `bash tools/shot.sh res://scenes/<scene>.tscn <name>`), run the light tests, commit.
   After redoing a held portrait variant, remove its line from `Portraits.HELD_EXPRESSIONS` in `core/data/portraits.gd`.

## 4. The music pipeline

Scores are Python in `tools/music/scores/`; `tools/music/build.py` renders them with FluidSynth + FluidR3_GM, `deliver.py` copies the
renders into the game, `bash tools/import_audio.sh` imports. Docs: `docs/audio/music_toolchain.md`, `docs/audio/score_bible.md`. A small
change ("make the town theme 10 s longer"): edit the score file, build that one cue, listen, deliver, import, commit.

## 5. The dialogue workflow

1. `node tools/export_dialogue.js` writes a CSV of every line in story order (ID, area, speaker, when, current line, new line).
2. Open it in Google Sheets; write changes in "New line" (leave the rest alone).
3. Download as CSV into `docs/dialogue/`, then `node tools/apply_dialogue_pass.js --csv=docs/dialogue/<file>.csv` (dry run report), then
   the same with `--apply`. It checks tokens, length and that the line fits the box. `--revert` puts a CSV's changes back.

## 6. Small, safe prompts for a $20 plan

Rules of thumb: one task per session; name the files; say what "done" means; ask for the light tests only; ask it to commit when green.
Start every prompt with: *"Repo C:\Dev\Deckbuilder-rpg, Godot 4.7.2. Read CLAUDE.md first. One Godot at a time. Don't export."*

1. **Fix a bug:** "Bug: <what you saw, where, how to repeat it>. Find the cause (start in <file if known>), fix it with the smallest change,
   add a GUT test that fails before the fix, run that test file and `tests/core`, commit."
2. **Tweak a card:** "Card <ID> (<name>) in data/cards/<ID>.tres: change <cost/stats/text> to <new>. Keep rules text and effect in step
   (core/game). Run tests/core/game and tests/core/data, commit."
3. **Add a quest line:** "Add a side quest in <zone>: given by <NPC> (spot <id>), steps: <1..n>, reward <gold/item>. Follow the pattern of
   <an existing quest id> in core/quests/zone_quest_definitions.gd, put its lines in the zone's story file, run `bash tools/quest_audit.sh`
   and tests/core/quests, commit."
4. **Import one image:** "I put <ID>.png in Drive Approved_<kind>. Import it with tools/import_<kind>.sh, check it shows where it should
   (<place>), take one screenshot, run the test for that importer, commit."
5. **Edit dialogue:** "Apply docs/dialogue/<file>.csv with tools/apply_dialogue_pass.js (dry run first, then --apply), show me the report,
   commit."
6. **Make a release build:** "Set config/version to <x.y.z> in project.godot, add a CHANGELOG line, run the full test suite in shards, then
   `bash tools/export_windows.sh` in the foreground and tell me the zip's path and size. Don't change anything else."

## 7. Known issues and the post-1.0 backlog (most important first)

See `docs/release/cut_or_finish_nov9.md` for detail and effort. In order:
1. Opening forest too dark / hero hidden by foliage / slab over the cave arch; a tutorial-cave loss restarts from the bedroll.
2. Crosspath: near roofs fill the view at the default camera.
3. Quiz: show right/wrong after each answer; check the Gainlands "mills and hamster wheels" answer key.
4. Dex's Matching Circuit looks placeholder (painted back, felt table, portrait).
5. Battle: played Infrastructure shows as a tiny card above the hand; 12-card hands overlap.
6. Batch 14 art redos (`docs/art/art_audit_nov9.md`): the species-flipping portrait variants (held in code for now), the giant-Primm and
   giant-chef stills, and the rest of the list.
7. Packs shelf scroll arrows; Alembic's essence bars; Wardrobe cloak tile tint; Gallery stale tooltip.
8. Autosave indicator; Path symbols on by default for colour-blind players.
9. CREDITS.md music section is out of date (the in-game Credits page is right).

## 8. Backups

- **GitHub:** every session ends with `git push` (the repo is the source of truth; large art stays in Drive and in the repo's `assets/`).
- **Drive copy:** once a week, zip the repo without `.godot/`, `builds/`, `_logs/`, `_screenshots/` (e.g. `git archive -o
  wayward_<date>.zip HEAD`) and put it in Drive next to the Approved_* folders. Keep the last 4.
- The Approved_* Drive folders are the art masters; never delete from them (old versions go to `Superseded/`).
