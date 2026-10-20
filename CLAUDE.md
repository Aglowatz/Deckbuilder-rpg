# Deckbuilder-RPG — Project Conventions

Godot 4.7.2, Forward+ renderer, single-player deckbuilder RPG.

## Language

- GDScript only. No C#, no GDExtension/native modules unless explicitly decided otherwise.
- Every script declares `class_name` when it's meant to be referenced elsewhere, and every
  file starts with `extends <Type>`.
- **Static typing is required.** Type all variables, function parameters, and return values
  (`var hp: int = 10`, `func apply(card: CardData) -> void:`). Avoid `var x = ...` inference
  for anything beyond obvious local temporaries, and never leave a function return type
  unannotated. Enable/keep the project's static-typing warnings on.
- Prefer `enum`s and typed `Resource` classes over stringly-typed data (magic strings for
  card ids, effect types, etc.).

## Game Rules

`docs/design/combat_rules.md` is the source of truth for game rules (resources, turn
structure, combat, win/lose, player stats, deck limits, mulligan). Implement `core/` against
it, and update that doc first if a rule needs to change.

## Architecture: rules vs. presentation

Card game rules logic must stay separate from presentation. This is the most important
structural rule in the project.

- `core/` — the rules engine. Deck, hand, turn order, card effect resolution, combat math,
  win/loss conditions. Pure GDScript logic: no `Node` scene-tree dependencies where avoidable,
  no direct references to `ui/` or `scenes/`, no `get_node()` reaching into presentation.
  Communicate outward via signals or return values, not by poking scene nodes directly.
- `data/` — card and encounter definitions (as `Resource`/`.tres` data, not baked into logic).
  `data/cards/` for card definitions, `data/encounters/` for encounter/enemy layouts.
- `scenes/` — top-level game scenes (`.tscn`) that assemble `core/` + `ui/` + `data/` together.
- `ui/` — presentation: visuals, animations, input handling, HUD, card visuals. UI reads game
  state from `core/` and calls into it to make moves; it never contains rules logic itself
  (e.g. "can this card be played" belongs in `core/`, not in a button's `_pressed()`).
- `assets/` — art, audio, fonts. See `CREDITS.md` — every non-original asset added here must
  get a corresponding license entry.
- `tests/` — GUT test scripts (`test_*.gd`), mirroring the structure of what they test.

Rule of thumb: `core/` should be testable and runnable with no scene tree and no rendering.
If a test for game logic needs a running scene to pass, that's a sign logic leaked into
presentation.

## Asset Policy

- **Approved sources:** Kenney, KayKit, Quaternius, game-icons.net, Google Fonts. Anything
  else (including OpenGameArt/Freesound) requires asking the user first.
- **Licenses:** CC0 preferred. CC BY allowed with attribution. Never use NC
  (non-commercial), ND, or unclear licenses.
- **Style lock:** the world uses a single low-poly family. Before adding a new pack, view its
  preview images and confirm it matches existing assets; if unsure, ask the user.
- **Workflow:** download packs into `_asset_library/<pack>/` (git-ignored). Copy only files
  actually used into `assets/`, keeping the pack's folder name and license file.
- **Credits:** every pack used needs a `CREDITS.md` entry: name, author, source URL,
  license, date.
- **Always tell the user when a new pack has been added.**
- **Build size:** the export budget is 800 MB (v0.3.1: 488 MB). Texture import settings per folder live in
  `tools/art_import_rules.json` (`docs/build_size_policy.md`); the import scripts apply them. Run exports with
  `bash tools/export_windows.sh`, which prints sizes by category and warns over budget. Working art stays in
  `_art_inbox/` / `_art_source/` (never exported).

## Testing

- Tests use the [GUT](https://github.com/bitwes/Gut) addon (`addons/gut/`), test scripts live
  in `tests/`, named `test_*.gd`, extending `GutTest`.
- Run headlessly from the project root:

  ```
  C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
  ```

- `core/` rules logic should be the primary thing under test — it's the part that doesn't
  need a scene tree to exercise.

- Balance: `Godot_console --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter=<group> --games=30 --out=res://docs/design/sim/<name>.md` (`core/sim/`; groups: tutorial, town, town:roamer, zone:<id>, dungeon:<ID>, side:<ID>, arena). Log every number change in `docs/design/balance_log.md`. Gear/items: `--what=gear --filter=<one fight> --games=8 [--pieces=a,b]` (each piece or item alone vs bare); economy: `Godot --headless --path . -s res://tools/economy_audit.gd`; one game's log: `-s res://tools/replay_encounter.gd -- --id=<spec id> --path=<path> --games=N --show=1`. Late games cost ~1.3 s each: one group per call, `--games=6` for a quick read.
- Windowed smokes (one Godot at a time): `bash tools/run_playtest_smoke.sh` (the opening hour: forest, Path choice, cave, Crosspath beside Maren, an outskirts fight, level 5, the armory quest, the deck racks), `bash tools/run_prologue_smoke.sh`, `bash tools/run_release_smoke.sh`.
- Old Well secret quest (overnight Oct 19): `bash tools/run_old_well_smoke.sh` (the vision, both hums in the Dump and the Buffet, the confirm, the brief, the Echo duel, the reveal, the relic; `OLD_WELL_SMOKE_API=1` skips loading the two zones).
- More checks (Oct 19): `bash tools/run_boss_rules_smoke.sh` (the Before-the-fight brief for Bellows and Shiro, HUD rule icons), `bash tools/run_onboarding_timing.sh` (New Game -> first saved deck edit with a reading model; `ONBOARD_PATH=necrocrat`), `bash tools/run_release_smoke_exported.sh` (the release smoke on the exported `builds/_export/TheWaywardPath.pck` - release templates ignore `--script`). Playtest feedback: `node tools/feedback_row.js [report folder | folder of reports]` -> `docs/playtest/feedback_log.md`.
- Sim noise: 50 runs on one seed can swing +/-10 points. Judge starter-deck or cave changes on two seeds (`--games=50 --seed=7000` and `--seed=8100`, 100 runs each) and boss changes with 25 games per Path on a second seed before keeping them.

## E2E testing budget

E2E testing budget: during proof-of-concept work, run the full e2e flow only for the area changed in the current task, in the foreground, at most twice. Re-run other zones' flows only if shared code they depend on changed, and cap total e2e time at about 15 minutes per task. Unit tests (GUT) still run after every part.

## Card pipeline

The card set comes from the designer's Google Sheet (CSV export in `data/source/`) through `tools/import_cards` into `data/cards/` and `data/tokens/`;
each card's rules text is a script in `data/scripts/`, and card art loads by convention from `assets/art/cards/<CardID>.webp`. Everything about
the pipeline, the script vocabulary and the re-import workflow is in `docs/card_pipeline.md`.
When the user says "import card art": run `bash tools/import_art.sh` and report what was added and what is still missing (`docs/art/art_pipeline.md`). Never create or fetch card art yourself.
When the user says "import portraits": run `bash tools/import_portraits.sh` (NPC dialogue portraits from the Drive `Approved_Characters` folder, copy-only; `docs/art/art_pipeline.md`) and report what was added, the Portrait Image IDs still missing and files that match no ID. Never create or fetch portrait art yourself.
When the user says "import maps": run `bash tools/import_maps.sh` (dungeon map art from the Drive `Approved_Maps` folder, copy-only, never cropped; `docs/art/art_pipeline.md`) and report what was added, the Map Image IDs still missing and files that match no ID. Never create or fetch map art yourself.
When the user says "import bestiary": run `bash tools/import_bestiary.sh` (Bestiary pictures BST-* from the Drive `Approved_Bestiary` folder, copy-only, square WebP into `assets/art/bestiary`; `docs/art/art_pipeline.md`) and report what was added, the Bestiary IDs still missing and files that match no ID. Never create or fetch bestiary art yourself.
When the user says "import UI art": run `bash tools/import_ui_art.sh` (the UI art kit from the Drive `Approved_UI` folder, copy-only; `docs/art/ui_art_kit.md`) and report what was added, the UI IDs still missing and files that match no ID. Never create or fetch UI art yourself.
When the user says "import env kit art": run `bash tools/import_env_kit.sh` (the Environment Kit art from the Drive `Approved_EnvKit` folder, copy-only; `docs/art/vertical_slice.md`) and report what was added, the kit IDs still missing and files that match no ID. Never create or fetch kit art yourself; a placeholder stays until its file exists.
When the user says "import zone kit <zone>" (for example "import zone kit gainlands"): run `bash tools/import_zone_kit.sh <zone>` (that zone's kit from the Drive `Approved_ZoneKits/<Zone>` folder, copy-only, listed in `data/source/<zone>_kit.csv`; `docs/art/zone_rollout_playbook.md`) and report what was added, the kit IDs still missing and files that match no ID. Never create or fetch kit art yourself.
