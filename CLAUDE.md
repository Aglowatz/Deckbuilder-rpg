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

## Testing

- Tests use the [GUT](https://github.com/bitwes/Gut) addon (`addons/gut/`), test scripts live
  in `tests/`, named `test_*.gd`, extending `GutTest`.
- Run headlessly from the project root:

  ```
  C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
  ```

- `core/` rules logic should be the primary thing under test — it's the part that doesn't
  need a scene tree to exercise.

## E2E testing budget

E2E testing budget: during proof-of-concept work, run the full e2e flow only for the area changed in the current task, in the foreground, at most twice. Re-run other zones' flows only if shared code they depend on changed, and cap total e2e time at about 15 minutes per task. Unit tests (GUT) still run after every part.

## Card pipeline

The card set comes from the designer's Google Sheet (CSV export in `data/source/`) through `tools/import_cards` into `data/cards/` and `data/tokens/`;
each card's rules text is a script in `data/scripts/`, and card art loads by convention from `assets/art/cards/<CardID>.webp`. Everything about
the pipeline, the script vocabulary and the re-import workflow is in `docs/card_pipeline.md`.
When the user says "import card art": run `bash tools/import_art.sh` and report what was added and what is still missing (`docs/art/art_pipeline.md`). Never create or fetch card art yourself.
When the user says "import portraits": run `bash tools/import_portraits.sh` (NPC dialogue portraits from the Drive `Approved_Characters` folder, copy-only; `docs/art/art_pipeline.md`) and report what was added, the Portrait Image IDs still missing and files that match no ID. Never create or fetch portrait art yourself.
